package com.pirci.prayer_assistant

import android.app.Activity
import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.DocumentsContract
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private lateinit var widgetChannel: MethodChannel
    private lateinit var backupFolderChannel: MethodChannel
    private var pendingOpenHome: Boolean = false
    private var pendingFolderResult: MethodChannel.Result? = null
    private val pickFolderRequest = 4097

    private val backupFolderPrefs by lazy {
        getSharedPreferences("backup_folder_prefs", Context.MODE_PRIVATE)
    }

    private fun storedFolderUri(): Uri? =
        backupFolderPrefs.getString("tree_uri", null)?.let { Uri.parse(it) }

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
                    val moonHijriDate = call.argument<String>("moonHijriDate") ?: ""
                    val moonGregorianDate = call.argument<String>("moonGregorianDate") ?: ""
                    val isWhiteDay = call.argument<Boolean>("isWhiteDay") ?: false
                    val whiteDayBadgeText = call.argument<String>("whiteDayBadgeText") ?: "White Days"

                    PrayerWidgetStorage.saveTimeline(this, timeline)
                    PrayerWidgetStorage.saveTodayPrayers(this, todayPrayers)
                    PrayerWidgetStorage.saveLocationLabel(this, locationLabel)
                    PrayerWidgetStorage.saveDateHeaders(this, dateHeaderHijri, dateHeaderGregorian)
                    PrayerWidgetStorage.saveWidgetCalendarDisplay(this, calendarDisplay)
                    PrayerWidgetStorage.saveWidgetShowSecondaryCalendar(this, showSecondaryDate)
                    PrayerWidgetStorage.saveMoonPhaseData(
                        this,
                        moonPhaseValue,
                        moonIllumination,
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
                "updateStatusBarConfig" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: true
                    PrayerWidgetStorage.saveStatusConfig(this, enabled, enabled)
                    PrayerWidgetUpdater.updateAll(this)
                    PrayerWidgetUpdater.scheduleNextUpdate(this)
                    PrayerWidgetUpdater.scheduleIconRefresh(this)
                    PrayerWidgetUpdater.scheduleWidgetMinuteRefresh(this)
                    PrayerWidgetUpdater.scheduleWidgetSecondRefresh(this)
                    result.success(null)
                }
                "consumePendingOpenHome" -> {
                    val shouldOpen = pendingOpenHome
                    pendingOpenHome = false
                    result.success(shouldOpen)
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
                else -> result.notImplemented()
            }
        }
        maybeNotifyOpenHome(intent)
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
        maybeNotifyOpenHome(intent)
    }

    private fun maybeNotifyOpenHome(intent: Intent?) {
        if (intent?.getBooleanExtra("open_home_tab", false) == true) {
            pendingOpenHome = true
        }
        if (!::widgetChannel.isInitialized) {
            return
        }
        if (pendingOpenHome) {
            pendingOpenHome = false
            widgetChannel.invokeMethod("openHomeTab", null)
        }
    }
}
