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
        onTap: (Long) -> Unit,
        onDismiss: (() -> Unit)? = null
    ) {
        if (view != null || Build.VERSION.SDK_INT < Build.VERSION_CODES.O || !canDraw(context)) return
        val app = context.applicationContext
        val wm = app.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val density = app.resources.displayMetrics.density
        val sizePx = (72 * density).toInt()
        val dismissSizePx = (46 * density).toInt()
        val dismissBottomMarginPx = (44 * density).toInt()

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

        val normalDismissBg = GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            setColor(Color.parseColor("#99000000"))
            setStroke((2 * density).toInt(), Color.WHITE)
        }
        val activeDismissBg = GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            setColor(Color.parseColor("#E53935"))
            setStroke((2 * density).toInt(), Color.WHITE)
        }

        val dismissParams = WindowManager.LayoutParams(
            dismissSizePx,
            dismissSizePx,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL
            y = dismissBottomMarginPx
        }

        fun vibrateDismissFeedback() {
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    val vm = app.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager
                    vm?.defaultVibrator?.vibrate(VibrationEffect.createOneShot(35, VibrationEffect.DEFAULT_AMPLITUDE))
                } else {
                    @Suppress("DEPRECATION")
                    val v = app.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        v?.vibrate(VibrationEffect.createOneShot(35, VibrationEffect.DEFAULT_AMPLITUDE))
                    } else {
                        @Suppress("DEPRECATION")
                        v?.vibrate(35)
                    }
                }
            } catch (_: Exception) {}
        }

        fun showDismissTarget() {
            if (dismissView == null) {
                val target = TextView(app).apply {
                    this.text = "✕"
                    gravity = Gravity.CENTER
                    setTextColor(Color.WHITE)
                    textSize = 18f
                    typeface = Typeface.DEFAULT_BOLD
                    background = normalDismissBg
                    elevation = 12f
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
                        val dist: Double
                        val threshold: Float
                        if (target != null && target.isAttachedToWindow) {
                            val targetLoc = IntArray(2)
                            target.getLocationOnScreen(targetLoc)
                            val targetCenterX = targetLoc[0] + (target.width / 2f)
                            val targetCenterY = targetLoc[1] + (target.height / 2f)

                            val bubbleLoc = IntArray(2)
                            bubble.getLocationOnScreen(bubbleLoc)
                            val bubbleCenterX = bubbleLoc[0] + (bubble.width / 2f)
                            val bubbleCenterY = bubbleLoc[1] + (bubble.height / 2f)

                            dist = hypot((bubbleCenterX - targetCenterX).toDouble(), (bubbleCenterY - targetCenterY).toDouble())
                            threshold = ((bubble.width + target.width) / 2f) * 0.9f
                        } else {
                            val metrics = app.resources.displayMetrics
                            val bubbleCenterX = params.x + (sizePx / 2f)
                            val bubbleCenterY = params.y + (sizePx / 2f)
                            val targetCenterX = metrics.widthPixels / 2f
                            val targetCenterY = metrics.heightPixels - dismissBottomMarginPx - (dismissSizePx / 2f)
                            dist = hypot((bubbleCenterX - targetCenterX).toDouble(), (bubbleCenterY - targetCenterY).toDouble())
                            threshold = (sizePx + dismissSizePx) / 2f
                        }

                        if (dist < threshold) {
                            if (!isOverDismiss) {
                                isOverDismiss = true
                                vibrateDismissFeedback()
                                dismissView?.background = activeDismissBg
                                dismissView?.scaleX = 1.25f
                                dismissView?.scaleY = 1.25f
                            }
                        } else {
                            if (isOverDismiss) {
                                isOverDismiss = false
                                dismissView?.background = normalDismissBg
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

    fun update(text: String) {
        view?.apply {
            this.text = text
            textSize = textSizeFor(text)
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
