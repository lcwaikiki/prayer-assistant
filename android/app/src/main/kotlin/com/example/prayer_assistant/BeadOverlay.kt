package com.pirci.prayer_assistant

import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.provider.Settings
import android.view.Gravity
import android.view.MotionEvent
import android.view.ViewConfiguration
import android.view.WindowManager
import android.widget.TextView
import kotlin.math.hypot

/**
 * Draggable floating bead counter drawn over other apps.
 * Tap counts a bead, long-press reopens the app, drag moves the bubble smoothly.
 */
object BeadOverlay {
    private const val PREFS_NAME = "bead_overlay_prefs"
    private const val KEY_LAST_X = "last_x"
    private const val KEY_LAST_Y = "last_y"

    private var view: TextView? = null
    private var dismissView: TextView? = null
    private var lastX: Int? = null
    private var lastY: Int? = null

    private fun getSavedPosition(context: Context): Pair<Int, Int> {
        val x = lastX
        val y = lastY
        if (x != null && y != null) {
            return Pair(x, y)
        }
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val savedX = prefs.getInt(KEY_LAST_X, 0)
        val savedY = prefs.getInt(KEY_LAST_Y, 300)
        lastX = savedX
        lastY = savedY
        return Pair(savedX, savedY)
    }

    private fun savePosition(context: Context, x: Int, y: Int) {
        lastX = x
        lastY = y
        try {
            context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .edit()
                .putInt(KEY_LAST_X, x)
                .putInt(KEY_LAST_Y, y)
                .apply()
        } catch (_: Exception) {}
    }

    fun canDraw(context: Context): Boolean = Settings.canDrawOverlays(context)

    val isShowing: Boolean get() = view != null

    @SuppressLint("ClickableViewAccessibility")
    fun show(
        context: Context,
        text: String,
        closeLabel: String? = null,
        onTap: (Long) -> Unit,
        onDismiss: (() -> Unit)? = null
    ) {
        if (view != null || Build.VERSION.SDK_INT < Build.VERSION_CODES.O || !canDraw(context)) return
        val app = context.applicationContext
        val wm = app.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val density = app.resources.displayMetrics.density
        val sizePx = (72 * density).toInt()
        val dismissHeightPx = (44 * density).toInt()
        val dismissWidthPx = (136 * density).toInt()
        val dismissBottomMarginPx = (-12 * density).toInt()
        val closeText = getCloseText(app, closeLabel)

        val (curX, curY) = getSavedPosition(app)
        val params = WindowManager.LayoutParams(
            sizePx,
            sizePx,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = curX
            y = curY
        }
        val bubble = TextView(app).apply {
            this.text = text
            gravity = Gravity.CENTER
            setTextColor(Color.WHITE)
            textSize = textSizeFor(text)
            typeface = Typeface.DEFAULT_BOLD
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.parseColor("#E61F8A70"))
                setStroke((2 * density).toInt(), Color.WHITE)
            }
            elevation = 8f
        }

        val normalTextColor = Color.parseColor("#3C4043")
        val activeTextColor = Color.WHITE

        val normalDismissBg = GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            cornerRadius = 22 * density
            setColor(Color.parseColor("#FFFFFFFF"))
            setStroke((2 * density).toInt(), Color.parseColor("#CCCCCC"))
            alpha = 255
        }
        val activeDismissBg = GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            cornerRadius = 22 * density
            setColor(Color.parseColor("#E53935"))
            setStroke((2 * density).toInt(), Color.parseColor("#C62828"))
            alpha = 255
        }

        val dismissParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            dismissHeightPx,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL
            y = dismissBottomMarginPx
            alpha = 1.0f
        }

        fun vibrateDismissFeedback() {
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    val vm = app.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager
                    vm?.defaultVibrator?.vibrate(VibrationEffect.createOneShot(8, VibrationEffect.DEFAULT_AMPLITUDE))
                } else {
                    @Suppress("DEPRECATION")
                    val v = app.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        v?.vibrate(VibrationEffect.createOneShot(8, VibrationEffect.DEFAULT_AMPLITUDE))
                    } else {
                        @Suppress("DEPRECATION")
                        v?.vibrate(8)
                    }
                }
            } catch (_: Exception) {}
        }

        fun showDismissTarget() {
            if (dismissView == null) {
                val target = TextView(app).apply {
                    this.text = "✕  $closeText"
                    gravity = Gravity.CENTER
                    setTextColor(normalTextColor)
                    textSize = 17f
                    typeface = try {
                        Typeface.create("sans-serif-medium", Typeface.NORMAL)
                    } catch (_: Exception) {
                        Typeface.DEFAULT_BOLD
                    }
                    background = normalDismissBg
                    elevation = 12f
                    alpha = 1.0f
                    minWidth = dismissWidthPx
                    setPadding((16 * density).toInt(), 0, (16 * density).toInt(), 0)
                }
                try {
                    wm.addView(target, dismissParams)
                    dismissView = target
                } catch (_: Exception) {}
            }
        }

        fun hideDismissTarget() {
            val target = dismissView ?: return
            try {
                wm.removeView(target)
            } catch (_: Exception) {}
            dismissView = null
        }

        val touchSlop = ViewConfiguration.get(app).scaledTouchSlop
        val longPressTimeout = 1000L
        val handler = Handler(Looper.getMainLooper())

        var initialX = 0
        var initialY = 0
        var initialTouchX = 0f
        var initialTouchY = 0f
        var isDragging = false
        var isLongPressed = false
        var isOverDismiss = false

        val longPressRunnable = Runnable {
            if (!isDragging) {
                isLongPressed = true
                openApp(app)
            }
        }

        bubble.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = params.x
                    initialY = params.y
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                    isDragging = false
                    isLongPressed = false
                    isOverDismiss = false
                    handler.removeCallbacks(longPressRunnable)
                    handler.postDelayed(longPressRunnable, longPressTimeout)
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = event.rawX - initialTouchX
                    val dy = event.rawY - initialTouchY
                    if (!isDragging && hypot(dx, dy) > touchSlop) {
                        isDragging = true
                        handler.removeCallbacks(longPressRunnable)
                        showDismissTarget()
                    }
                    if (isDragging) {
                        params.x = (initialX + dx).toInt()
                        params.y = (initialY + dy).toInt()
                        try {
                            wm.updateViewLayout(bubble, params)
                        } catch (_: Exception) {}

                        val target = dismissView
                        val isOver: Boolean
                        if (target != null && target.isAttachedToWindow) {
                            val targetLoc = IntArray(2)
                            target.getLocationOnScreen(targetLoc)
                            val targetLeft = targetLoc[0].toFloat()
                            val targetTop = targetLoc[1].toFloat()
                            val targetRight = targetLeft + target.width
                            val targetBottom = targetTop + target.height

                            val bubbleLoc = IntArray(2)
                            bubble.getLocationOnScreen(bubbleLoc)
                            val bubbleCenterX = bubbleLoc[0] + (bubble.width / 2f)
                            val bubbleCenterY = bubbleLoc[1] + (bubble.height / 2f)

                            val clampX = bubbleCenterX.coerceIn(targetLeft, targetRight)
                            val clampY = bubbleCenterY.coerceIn(targetTop, targetBottom)
                            val dist = hypot((bubbleCenterX - clampX).toDouble(), (bubbleCenterY - clampY).toDouble())
                            isOver = dist <= (bubble.width / 2f)
                        } else {
                            val metrics = app.resources.displayMetrics
                            val targetLeft = (metrics.widthPixels - dismissWidthPx) / 2f
                            val targetTop = (metrics.heightPixels - dismissBottomMarginPx - dismissHeightPx).toFloat()
                            val targetRight = targetLeft + dismissWidthPx
                            val targetBottom = targetTop + dismissHeightPx
                            val bubbleCenterX = params.x + (sizePx / 2f)
                            val bubbleCenterY = params.y + (sizePx / 2f)
                            val clampX = bubbleCenterX.coerceIn(targetLeft, targetRight)
                            val clampY = bubbleCenterY.coerceIn(targetTop, targetBottom)
                            val dist = hypot((bubbleCenterX - clampX).toDouble(), (bubbleCenterY - clampY).toDouble())
                            isOver = dist <= (sizePx / 2f)
                        }

                        if (isOver) {
                            if (!isOverDismiss) {
                                isOverDismiss = true
                                vibrateDismissFeedback()
                                dismissView?.background = activeDismissBg
                                dismissView?.setTextColor(activeTextColor)
                                dismissView?.scaleX = 1.08f
                                dismissView?.scaleY = 1.08f
                            }
                        } else {
                            if (isOverDismiss) {
                                isOverDismiss = false
                                vibrateDismissFeedback()
                                dismissView?.background = normalDismissBg
                                dismissView?.setTextColor(normalTextColor)
                                dismissView?.scaleX = 1.0f
                                dismissView?.scaleY = 1.0f
                            }
                        }
                    }
                    true
                }
                MotionEvent.ACTION_UP -> {
                    handler.removeCallbacks(longPressRunnable)
                    hideDismissTarget()
                    if (isOverDismiss) {
                        savePosition(app, initialX, initialY)
                        hide(app)
                        onDismiss?.invoke()
                    } else {
                        if (isDragging) {
                            savePosition(app, params.x, params.y)
                        }
                        if (!isDragging && !isLongPressed) {
                            onTap(System.currentTimeMillis())
                        }
                    }
                    true
                }
                MotionEvent.ACTION_CANCEL -> {
                    handler.removeCallbacks(longPressRunnable)
                    hideDismissTarget()
                    if (isOverDismiss) {
                        savePosition(app, initialX, initialY)
                    }
                    true
                }
                else -> false
            }
        }

        wm.addView(bubble, params)
        view = bubble
    }

    fun update(text: String, closeLabel: String? = null) {
        view?.apply {
            this.text = text
            textSize = textSizeFor(text)
        }
        if (closeLabel != null) {
            dismissView?.apply {
                this.text = "✕  $closeLabel"
            }
        }
    }

    private fun getCloseText(context: Context, customLabel: String? = null): String {
        val appLocale = PrayerWidgetStorage.readAppLocale(context).lowercase()
        val lang = if (appLocale.isNotEmpty()) {
            appLocale.split("-", "_")[0]
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            context.resources.configuration.locales[0]?.language?.lowercase()
        } else {
            @Suppress("DEPRECATION")
            context.resources.configuration.locale?.language?.lowercase()
        } ?: "en"

        if (!customLabel.isNullOrBlank() && (lang == "en" || customLabel != "Close")) {
            return customLabel
        }

        return when (lang) {
            "tr" -> "Kapat"
            "ar" -> "إغلاق"
            "bn" -> "বন্ধ করুন"
            "de" -> "Schließen"
            "es" -> "Cerrar"
            "fa" -> "بستن"
            "fr" -> "Fermer"
            "id" -> "Tutup"
            "it" -> "Chiudi"
            "ja" -> "閉じる"
            "pt" -> "Fechar"
            "ru" -> "Закрыть"
            "ta" -> "மூடு"
            "ur" -> "بند کریں"
            "zh" -> "关闭"
            else -> customLabel?.takeIf { it.isNotBlank() } ?: "Close"
        }
    }

    private fun textSizeFor(text: String): Float = if (text.length <= 3) 20f else 15f

    fun hide(context: Context) {
        val wm = context.applicationContext.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val target = dismissView
        if (target != null) {
            try {
                wm.removeView(target)
            } catch (_: Exception) {}
            dismissView = null
        }
        val bubble = view ?: return
        try {
            wm.removeView(bubble)
        } catch (_: Exception) {}
        view = null
    }

    private fun openApp(context: Context) {
        val intent = Intent(context, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }
        context.startActivity(intent)
    }
}
