package com.pirci.prayer_assistant

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.ContentResolver
import android.content.ContentUris
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.DocumentsContract
import android.provider.MediaStore
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    companion object {
        private var instance: MainActivity? = null

        fun onNotificationAction(actionId: String, id: Int, payload: String?) {
            instance?.runOnUiThread {
                instance?.reminderChannel?.invokeMethod(
                    "onNotificationAction",
                    mapOf(
                        "actionId" to actionId,
                        "id" to id,
                        "payload" to payload
                    )
                )
            }
        }
    }

    private lateinit var widgetChannel: MethodChannel
    private lateinit var backupFolderChannel: MethodChannel
    private var reminderChannel: MethodChannel? = null
    private var beadOverlayChannel: MethodChannel? = null
    /** Bubble text while the bead execution screen is open; null otherwise. */
    private var beadOverlayText: String? = null
    private var pendingReminderPayload: String? = null
    private var pendingReminderId: Int? = null
    private var pendingOpenTarget: String? = null
    private var pendingFolderResult: MethodChannel.Result? = null
    private val pickFolderRequest = 4097
    private var screenReceiverRegistered = false

    /**
     * Context-registered screen-on/unlock listener. Manifest receivers for these
     * implicit broadcasts no longer fire on Android 8+, so it lives here while the
     * activity exists; [onResume] covers the foreground case and this covers an
     * unlock that lands on the home screen while the app is backgrounded.
     */
    private val screenReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent?) {
            PrayerWidgetUpdater.screenOnRefresh(context)
        }
    }

    private val backupFolderPrefs by lazy {
        getSharedPreferences("backup_folder_prefs", Context.MODE_PRIVATE)
    }

    private fun storedFolderUri(): Uri? =
        backupFolderPrefs.getString("tree_uri", null)?.let { Uri.parse(it) }

    /// Document URI for the shared Documents folder, used to open the folder
    /// picker there by default. Null when the provider is unavailable.
    private fun defaultDocumentsUri(): Uri? = try {
        DocumentsContract.buildDocumentUri(
            "com.android.externalstorage.documents",
            "primary:Documents"
        )
    } catch (_: Exception) {
        null
    }

    private fun documentChildrenUri(treeUri: Uri): Uri =
        DocumentsContract.buildChildDocumentsUriUsingTree(
            treeUri,
            DocumentsContract.getTreeDocumentId(treeUri)
        )

    private fun findChildDocument(
        resolver: ContentResolver,
        treeUri: Uri,
        name: String
    ): Uri? {
        val columns = arrayOf(
            DocumentsContract.Document.COLUMN_DOCUMENT_ID,
            DocumentsContract.Document.COLUMN_DISPLAY_NAME,
            DocumentsContract.Document.COLUMN_MIME_TYPE
        )
        resolver.query(
            documentChildrenUri(treeUri),
            columns,
            null,
            null,
            null
        )?.use { cursor ->
            val idIndex =
                cursor.getColumnIndex(DocumentsContract.Document.COLUMN_DOCUMENT_ID)
            val nameIndex =
                cursor.getColumnIndex(DocumentsContract.Document.COLUMN_DISPLAY_NAME)
            val mimeIndex =
                cursor.getColumnIndex(DocumentsContract.Document.COLUMN_MIME_TYPE)
            if (idIndex < 0 || nameIndex < 0) {
                return null
            }
            while (cursor.moveToNext()) {
                val isDirectory = mimeIndex >= 0 &&
                    cursor.getString(mimeIndex) == DocumentsContract.Document.MIME_TYPE_DIR
                if (!isDirectory && cursor.getString(nameIndex) == name) {
                    val docId = cursor.getString(idIndex)
                    return DocumentsContract.buildDocumentUriUsingTree(
                        treeUri,
                        docId
                    )
                }
            }
        }
        return null
    }

    private fun writeDocument(
        resolver: ContentResolver,
        treeUri: Uri,
        name: String,
        mime: String,
        content: String
    ): Boolean {
        var docUri = findChildDocument(resolver, treeUri, name)
        if (docUri == null) {
            val parent = DocumentsContract.buildDocumentUriUsingTree(
                treeUri,
                DocumentsContract.getTreeDocumentId(treeUri)
            )
            docUri = DocumentsContract.createDocument(resolver, parent, mime, name)
                ?: return false
        }
        resolver.openOutputStream(docUri, "wt")?.use { out ->
            out.write(content.toByteArray(Charsets.UTF_8))
            out.flush()
            return true
        }
        return false
    }

    private fun readDocument(
        resolver: ContentResolver,
        treeUri: Uri,
        name: String
    ): String? {
        val docUri = findChildDocument(resolver, treeUri, name) ?: return null
        return resolver.openInputStream(docUri)?.use { input ->
            input.readBytes().toString(Charsets.UTF_8)
        }
    }

    private val documentsRelativePath = "${Environment.DIRECTORY_DOCUMENTS}/"

    private fun documentsDirectory(): File = Environment
        .getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS)

    private fun documentsFolderExists(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // Scoped storage blocks stat() on the public path, so probe the
            // MediaStore Documents collection instead.
            return try {
                contentResolver.query(
                    defaultDocumentsCollection(),
                    arrayOf(MediaStore.MediaColumns._ID),
                    null,
                    null,
                    null
                ) != null
            } catch (_: Exception) {
                false
            }
        }
        return documentsDirectory().exists()
    }

    private fun documentsFile(name: String): File = File(documentsDirectory(), name)

    private fun defaultDocumentsCollection(): Uri =
        MediaStore.Files.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)

    private fun findDocumentsEntry(name: String): Uri? {
        contentResolver.query(
            defaultDocumentsCollection(),
            arrayOf(
                MediaStore.MediaColumns._ID,
                MediaStore.MediaColumns.DISPLAY_NAME,
                MediaStore.MediaColumns.RELATIVE_PATH
            ),
            "${MediaStore.MediaColumns.DISPLAY_NAME} = ?",
            arrayOf(name),
            null
        )?.use { cursor ->
            val idIndex = cursor.getColumnIndex(MediaStore.MediaColumns._ID)
            val nameIndex =
                cursor.getColumnIndex(MediaStore.MediaColumns.DISPLAY_NAME)
            val pathIndex =
                cursor.getColumnIndex(MediaStore.MediaColumns.RELATIVE_PATH)
            while (cursor.moveToNext()) {
                val display = cursor.getString(nameIndex)
                val relative = cursor.getString(pathIndex)
                if (display == name &&
                    relative != null &&
                    relative.startsWith(Environment.DIRECTORY_DOCUMENTS)
                ) {
                    val id = cursor.getLong(idIndex)
                    return ContentUris.withAppendedId(
                        defaultDocumentsCollection(),
                        id
                    )
                }
            }
        }
        return null
    }

    private fun writeDocumentsBackup(name: String, content: String): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            return try {
                val file = documentsFile(name)
                if (!documentsFolderExists()) return false
                file.writeText(content, Charsets.UTF_8)
                true
            } catch (_: Exception) {
                false
            }
        }
        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, name)
            put(MediaStore.MediaColumns.MIME_TYPE, "application/json")
            put(MediaStore.MediaColumns.RELATIVE_PATH, documentsRelativePath)
        }
        val uri = findDocumentsEntry(name)
            ?: contentResolver.insert(defaultDocumentsCollection(), values)
            ?: return false
        return try {
            contentResolver.openOutputStream(uri, "wt")?.use { out ->
                out.write(content.toByteArray(Charsets.UTF_8))
                out.flush()
            } != null
        } catch (_: Exception) {
            false
        }
    }

    private fun readDocumentsBackup(name: String): String? {
        val uri = findDocumentsEntry(name) ?: documentsFile(name)
            .takeIf { it.exists() }
            ?.let { Uri.fromFile(it) }
            ?: return null
        return try {
            contentResolver.openInputStream(uri)?.use { input ->
                input.readBytes().toString(Charsets.UTF_8)
            }
        } catch (_: Exception) {
            null
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        widgetChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "prayer_assistant/widget"
        )
        widgetChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "updateWidgetData" -> {
                    val timeline = call.argument<List<Map<String, Any?>>>("timeline") ?: emptyList()
                    val todayPrayers = call.argument<List<Map<String, Any?>>>("todayPrayers") ?: emptyList()
                    val locationLabel = call.argument<String>("locationLabel") ?: ""
                    val appLocale = call.argument<String>("appLocale") ?: ""
                    val dateHeaderHijri = call.argument<String>("dateHeaderHijri") ?: ""
                    val dateHeaderGregorian = call.argument<String>("dateHeaderGregorian") ?: ""
                    val calendarDisplay = call.argument<String>("calendarDisplay") ?: "hijri"
                    val showSecondaryDate = call.argument<Boolean>("showSecondaryDate") ?: true
                    val moonPhaseValue = call.argument<Double>("moonPhaseValue") ?: 0.5
                    val moonIllumination = call.argument<Double>("moonIllumination") ?: 50.0
                    val moonPhaseName = call.argument<String>("moonPhaseName") ?: ""
                    val moonIlluminationText = call.argument<String>("moonIlluminationText") ?: ""
                    val moonHijriDate = call.argument<String>("moonHijriDate") ?: ""
                    val moonGregorianDate = call.argument<String>("moonGregorianDate") ?: ""
                    val isWhiteDay = call.argument<Boolean>("isWhiteDay") ?: false
                    val whiteDayBadgeText = call.argument<String>("whiteDayBadgeText") ?: "White Days"
                    val weekStart = call.argument<String>("weekStart") ?: "monday"

                    PrayerWidgetStorage.saveTimeline(this, timeline)
                    PrayerWidgetStorage.saveTodayPrayers(this, todayPrayers)
                    PrayerWidgetStorage.saveLocationLabel(this, locationLabel)
                    PrayerWidgetStorage.saveDateHeaders(this, dateHeaderHijri, dateHeaderGregorian)
                    PrayerWidgetStorage.saveWidgetCalendarDisplay(this, calendarDisplay)
                    PrayerWidgetStorage.saveWidgetShowSecondaryCalendar(this, showSecondaryDate)
                    PrayerWidgetStorage.saveWeekStart(this, weekStart)
                    PrayerWidgetStorage.saveMoonPhaseData(
                        this,
                        moonPhaseValue,
                        moonIllumination,
                        moonIlluminationText,
                        moonPhaseName,
                        moonHijriDate,
                        moonGregorianDate,
                        isWhiteDay,
                        whiteDayBadgeText
                    )

                    if (appLocale.isNotEmpty()) {
                        PrayerWidgetStorage.saveAppLocale(this, appLocale)
                    }
                    PrayerWidgetUpdater.updateAll(this)
                    PrayerWidgetUpdater.scheduleNextUpdate(this)
                    PrayerWidgetUpdater.scheduleIconRefresh(this)
                    PrayerWidgetUpdater.scheduleWidgetMinuteRefresh(this)
                    PrayerWidgetUpdater.scheduleWidgetSecondRefresh(this)
                    result.success(null)
                }
                "updateWidgetLocale" -> {
                    val locale = call.argument<String>("locale") ?: ""
                    if (locale.isNotEmpty()) {
                        PrayerWidgetStorage.saveAppLocale(this, locale)
                        PrayerWidgetUpdater.updateAll(this)
                    }
                    result.success(null)
                }
                "updateCalendarReminders" -> {
                    val headerText = call.argument<String>("headerText") ?: "Upcoming reminders"
                    val reminders = call.argument<List<Map<String, Any?>>>("reminders") ?: emptyList()
                    PrayerWidgetStorage.saveCalendarRemindersHeader(this, headerText)
                    PrayerWidgetStorage.saveCalendarReminders(this, reminders)
                    PrayerWidgetUpdater.updateAll(this)
                    result.success(null)
                }
                "updateWidgetTextSize" -> {
                    val size = call.argument<String>("size") ?: "medium"
                    PrayerWidgetStorage.saveWidgetTextSize(this, size)
                    PrayerWidgetUpdater.updateAll(this)
                    result.success(null)
                }
                "updateWidgetTheme" -> {
                    val theme = call.argument<String>("theme") ?: "system"
                    PrayerWidgetStorage.saveWidgetTheme(this, theme)
                    PrayerWidgetUpdater.updateAll(this)
                    result.success(null)
                }
                "updateWidgetCalendarDisplay" -> {
                    val display = call.argument<String>("display") ?: "hijri"
                    val showSecondaryDate = call.argument<Boolean>("showSecondaryDate") ?: true
                    PrayerWidgetStorage.saveWidgetCalendarDisplay(this, display)
                    PrayerWidgetStorage.saveWidgetShowSecondaryCalendar(this, showSecondaryDate)
                    PrayerWidgetUpdater.updateAll(this)
                    result.success(null)
                }
                "updateWidgetMmssThreshold" -> {
                    val minutes = call.argument<Int>("minutes") ?: 60
                    PrayerWidgetStorage.saveWidgetMmssThreshold(this, minutes)
                    PrayerWidgetUpdater.updateAll(this)
                    result.success(null)
                }
                "updateSnoozeDurationMinutes" -> {
                    val minutes = call.argument<Int>("minutes") ?: 10
                    PrayerWidgetStorage.saveSnoozeDurationMinutes(this, minutes)
                    result.success(null)
                }
                "updateDismissConfirm" -> {
                    val dismissConfirm = call.argument<Boolean>("dismissConfirm") ?: true
                    PrayerWidgetStorage.saveDismissConfirm(this, dismissConfirm)
                    result.success(null)
                }
                "updateStatusBarConfig" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: true
                    val showTimeLeft = call.argument<Boolean>("showTimeLeft") ?: true
                    val showPrayerTimes = call.argument<Boolean>("showPrayerTimes") ?: true
                    PrayerWidgetStorage.saveStatusConfig(this, enabled, enabled, showTimeLeft, showPrayerTimes)
                    PrayerWidgetUpdater.updateAll(this)
                    PrayerWidgetUpdater.scheduleNextUpdate(this)
                    PrayerWidgetUpdater.scheduleIconRefresh(this)
                    PrayerWidgetUpdater.scheduleWidgetMinuteRefresh(this)
                    PrayerWidgetUpdater.scheduleWidgetSecondRefresh(this)
                    result.success(null)
                }
                "updateQadaaWidget" -> {
                    QadaaWidgetStorage.saveState(this, call.arguments as Map<String, Any?>)
                    QadaaWidgetProvider.updateWidgets(this)
                    result.success(null)
                }
                "consumeQadaaPending" -> {
                    result.success(QadaaWidgetStorage.consumePending(this))
                }
                "consumePendingOpenTarget" -> {
                    val target = pendingOpenTarget
                    pendingOpenTarget = null
                    result.success(target)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        backupFolderChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "prayer_assistant/backup_folder"
        )
        backupFolderChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "pickFolder" -> {
                    pendingFolderResult = result
                    val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                        addFlags(
                            Intent.FLAG_GRANT_READ_URI_PERMISSION or
                                Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                                Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION
                        )
                        val start = storedFolderUri() ?: defaultDocumentsUri()
                        if (start != null) {
                            putExtra(DocumentsContract.EXTRA_INITIAL_URI, start)
                        }
                    }
                    try {
                        startActivityForResult(intent, pickFolderRequest)
                    } catch (e: Exception) {
                        pendingFolderResult = null
                        result.error("pick_failed", e.message, null)
                    }
                }
                "hasFolder" -> result.success(storedFolderUri()?.toString())
                "clearFolder" -> {
                    storedFolderUri()?.let { uri ->
                        try {
                            contentResolver.releasePersistableUriPermission(
                                uri,
                                Intent.FLAG_GRANT_READ_URI_PERMISSION or
                                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                            )
                        } catch (_: SecurityException) {
                        }
                    }
                    backupFolderPrefs.edit().remove("tree_uri").apply()
                    result.success(null)
                }
                "writeBackup" -> {
                    val content = call.argument<String>("content") ?: ""
                    val name = call.argument<String>("fileName")
                        ?: "prayer_assistant_backup.json"
                    val treeUri = storedFolderUri()
                    try {
                        result.success(
                            treeUri != null &&
                                writeDocument(
                                    contentResolver,
                                    treeUri,
                                    name,
                                    "application/json",
                                    content
                                )
                        )
                    } catch (e: Exception) {
                        result.error("write_failed", e.message, null)
                    }
                }
                "readBackup" -> {
                    val name = call.argument<String>("fileName")
                        ?: "prayer_assistant_backup.json"
                    val treeUri = storedFolderUri()
                    try {
                        result.success(
                            treeUri?.let { readDocument(contentResolver, it, name) }
                        )
                    } catch (e: Exception) {
                        result.error("read_failed", e.message, null)
                    }
                }
                "documentsFolderAvailable" -> {
                    result.success(documentsFolderExists())
                }
                "writeDocumentsBackup" -> {
                    val content = call.argument<String>("content") ?: ""
                    val name = call.argument<String>("fileName")
                        ?: "prayer_assistant_backup.json"
                    result.success(writeDocumentsBackup(name, content))
                }
                "readDocumentsBackup" -> {
                    val name = call.argument<String>("fileName")
                        ?: "prayer_assistant_backup.json"
                    result.success(readDocumentsBackup(name))
                }
                else -> result.notImplemented()
            }
        }
        val reminderChannelInstance = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "prayer_assistant/native_reminders"
        )
        reminderChannel = reminderChannelInstance
        reminderChannelInstance.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialPayload" -> {
                    val p = pendingReminderPayload
                    pendingReminderPayload = null
                    val id = pendingReminderId
                    pendingReminderId = null
                    result.success(if (p != null) mapOf("payload" to p, "id" to id) else null)
                }
                "updateDismissConfirm" -> {
                    val dismissConfirm = call.argument<Boolean>("dismissConfirm") ?: true
                    PrayerWidgetStorage.saveDismissConfirm(this, dismissConfirm)
                    result.success(null)
                }
                "show" -> {
                    val id = call.argument<Int>("id") ?: 0
                    val title = call.argument<String>("title") ?: ""
                    val body = call.argument<String>("body") ?: ""
                    val payload = call.argument<String>("payload")
                    val snoozeLabel = call.argument<String>("snoozeLabel") ?: "Snooze"
                    val dismissLabel = call.argument<String>("dismissLabel") ?: "Dismiss"
                    val doneLabel = call.argument<String>("doneLabel") ?: "Done"
                    val showDone = call.argument<Boolean>("showDone") ?: false
                    val soundResource = call.argument<String>("soundResource")
                    val originalTime = call.argument<String>("originalTime")
                    val dismissConfirm = call.argument<Boolean>("dismissConfirm")
                        ?: PrayerWidgetStorage.readDismissConfirm(this)
                    PrayerWidgetStorage.saveDismissConfirm(this, dismissConfirm)
                    ReminderNotificationManager.show(
                        context = this,
                        id = id,
                        title = title,
                        body = body,
                        payload = payload,
                        snoozeLabel = snoozeLabel,
                        dismissLabel = dismissLabel,
                        doneLabel = doneLabel,
                        showDone = showDone,
                        soundResource = soundResource,
                        originalTime = originalTime,
                        dismissConfirm = dismissConfirm
                    )
                    result.success(null)
                }
                "schedule" -> {
                    val id = call.argument<Int>("id") ?: 0
                    val triggerAtMillis = call.argument<Number>("triggerAtMillis")?.toLong() ?: System.currentTimeMillis()
                    val title = call.argument<String>("title") ?: ""
                    val body = call.argument<String>("body") ?: ""
                    val payload = call.argument<String>("payload")
                    val snoozeLabel = call.argument<String>("snoozeLabel") ?: "Snooze"
                    val dismissLabel = call.argument<String>("dismissLabel") ?: "Dismiss"
                    val doneLabel = call.argument<String>("doneLabel") ?: "Done"
                    val showDone = call.argument<Boolean>("showDone") ?: false
                    val soundResource = call.argument<String>("soundResource")
                    val originalTime = call.argument<String>("originalTime")
                    val dismissConfirm = call.argument<Boolean>("dismissConfirm")
                        ?: PrayerWidgetStorage.readDismissConfirm(this)
                    PrayerWidgetStorage.saveDismissConfirm(this, dismissConfirm)
                    ReminderNotificationManager.schedule(
                        context = this,
                        id = id,
                        triggerAtMillis = triggerAtMillis,
                        title = title,
                        body = body,
                        payload = payload,
                        snoozeLabel = snoozeLabel,
                        dismissLabel = dismissLabel,
                        doneLabel = doneLabel,
                        showDone = showDone,
                        soundResource = soundResource,
                        originalTime = originalTime,
                        dismissConfirm = dismissConfirm
                    )
                    result.success(null)
                }
                "cancel" -> {
                    val id = call.argument<Int>("id") ?: 0
                    ReminderNotificationManager.cancel(this, id)
                    result.success(null)
                }
                "scheduleSilentMode" -> {
                    val id = call.argument<Int>("id") ?: 0
                    val triggerAtMillis = call.argument<Number>("triggerAtMillis")?.toLong() ?: System.currentTimeMillis()
                    val durationMinutes = call.argument<Int>("durationMinutes") ?: 15
                    PrayerSilentModeManager.scheduleSilentMode(this, id, triggerAtMillis, durationMinutes)
                    result.success(null)
                }
                "cancelSilentMode" -> {
                    val id = call.argument<Int>("id") ?: 0
                    PrayerSilentModeManager.cancelSilentMode(this, id)
                    result.success(null)
                }
                "cancelAllSilentMode" -> {
                    PrayerSilentModeManager.cancelAll(this)
                    result.success(null)
                }
                "hasDndPermission" -> {
                    result.success(PrayerSilentModeManager.hasDndPermission(this))
                }
                "openDndSettings" -> {
                    PrayerSilentModeManager.openDndSettings(this)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        configureBeadOverlayChannel(flutterEngine)
        maybeNotifyOpenTarget(intent)
        maybeNotifyReminderTap(intent)
    }

    private fun configureBeadOverlayChannel(flutterEngine: FlutterEngine) {
        val channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "prayer_assistant/bead_overlay"
        )
        beadOverlayChannel = channel
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "hasPermission" -> result.success(BeadOverlay.canDraw(this))
                "requestPermission" -> {
                    startActivity(
                        Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:$packageName")
                        )
                    )
                    result.success(null)
                }
                "arm" -> {
                    beadOverlayText = call.argument<String>("text")
                    BeadOverlay.update(beadOverlayText ?: "")
                    result.success(null)
                }
                "disarm" -> {
                    beadOverlayText = null
                    BeadOverlay.hide(this)
                    result.success(null)
                }
                "openApp" -> {
                    val app = applicationContext
                    val intent = Intent(app, MainActivity::class.java).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                    }
                    app.startActivity(intent)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        val text = beadOverlayText ?: return
        if (BeadOverlay.canDraw(this)) {
            BeadOverlay.show(this, text) {
                beadOverlayChannel?.invokeMethod("tap", null)
            }
        } else {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            ).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            try {
                startActivity(intent)
            } catch (_: Exception) {}
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == pickFolderRequest) {
            val result = pendingFolderResult
            pendingFolderResult = null
            val uri = data?.data
            if (resultCode == Activity.RESULT_OK && uri != null) {
                val flags = data.flags and (
                    Intent.FLAG_GRANT_READ_URI_PERMISSION or
                        Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                )
                try {
                    contentResolver.takePersistableUriPermission(uri, flags)
                } catch (_: SecurityException) {
                }
                backupFolderPrefs.edit().putString("tree_uri", uri.toString()).apply()
                result?.success(uri.toString())
            } else {
                result?.success(null)
            }
            return
        }
        super.onActivityResult(requestCode, resultCode, data)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        maybeNotifyOpenTarget(intent)
        maybeNotifyReminderTap(intent)
    }

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        instance = this
        if (!screenReceiverRegistered) {
            val filter = IntentFilter().apply {
                addAction(Intent.ACTION_SCREEN_ON)
                addAction(Intent.ACTION_USER_PRESENT)
            }
            registerReceiver(screenReceiver, filter)
            screenReceiverRegistered = true
        }
    }

    override fun onDestroy() {
        if (instance == this) {
            instance = null
        }
        if (screenReceiverRegistered) {
            unregisterReceiver(screenReceiver)
            screenReceiverRegistered = false
        }
        super.onDestroy()
    }

    /**
     * Re-renders widgets and the status-bar icon whenever the app comes back to
     * the foreground (including right after the screen turns on). Widget/icon
     * bitmaps are static and their exact alarms can be deferred by Doze, so
     * without this the launcher shows a stale or blank snapshot at screen-on.
     */
    override fun onResume() {
        super.onResume()
        BeadOverlay.hide(this)
        PrayerWidgetUpdater.screenOnRefresh(this)
    }

    /** Forwards the screen a widget or the status bar asked to open. */
    private fun maybeNotifyOpenTarget(intent: Intent?) {
        intent?.getStringExtra(PrayerWidgetUpdater.EXTRA_OPEN_TARGET)?.let {
            pendingOpenTarget = it
        }
        if (intent?.getBooleanExtra("open_home_tab", false) == true) {
            pendingOpenTarget = PrayerWidgetUpdater.TARGET_TODAY
        }
        if (!::widgetChannel.isInitialized) {
            return
        }
        val target = pendingOpenTarget ?: return
        pendingOpenTarget = null
        widgetChannel.invokeMethod("openTarget", target)
    }

    private fun maybeNotifyReminderTap(intent: Intent?) {
        val payload = intent?.getStringExtra("payload")
        val id = intent?.getIntExtra("notification_id", -1) ?: -1
        val title = intent?.getStringExtra("title")
        val body = intent?.getStringExtra("body")
        val snoozeLabel = intent?.getStringExtra("snoozeLabel") ?: "Snooze"
        val dismissLabel = intent?.getStringExtra("dismissLabel") ?: "Dismiss"
        val doneLabel = intent?.getStringExtra("doneLabel") ?: "Done"
        val showDone = intent?.getBooleanExtra("showDone", false) ?: false
        val soundResource = intent?.getStringExtra("soundResource")

        if (id != -1 && title != null && body != null) {
            ReminderNotificationManager.show(
                context = this,
                id = id,
                title = title,
                body = body,
                payload = payload,
                snoozeLabel = snoozeLabel,
                dismissLabel = dismissLabel,
                doneLabel = doneLabel,
                showDone = showDone,
                soundResource = soundResource
            )
        }

        if (payload != null && payload.isNotEmpty()) {
            pendingReminderPayload = payload
            pendingReminderId = if (id != -1) id else null
            intent.removeExtra("payload")
            intent.removeExtra("notification_id")
            intent.removeExtra("title")
            intent.removeExtra("body")
            intent.removeExtra("snoozeLabel")
            intent.removeExtra("dismissLabel")
            intent.removeExtra("doneLabel")
            intent.removeExtra("showDone")
            intent.removeExtra("soundResource")
        }
        val ch = reminderChannel ?: return
        val currentPayload = pendingReminderPayload ?: return
        val currentId = pendingReminderId
        pendingReminderPayload = null
        pendingReminderId = null
        ch.invokeMethod(
            "onNotificationTap",
            mapOf(
                "payload" to currentPayload,
                "id" to currentId
            )
        )
    }
}
