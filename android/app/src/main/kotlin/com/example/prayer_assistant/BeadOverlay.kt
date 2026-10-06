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
    private var view: TextView? = null
    private var lastX = 0
    private var lastY = 300

    fun canDraw(context: Context): Boolean = Settings.canDrawOverlays(context)

    val isShowing: Boolean get() = view != null

    @SuppressLint("ClickableViewAccessibility")
    fun show(context: Context, text: String, onTap: () -> Unit) {
        if (view != null || Build.VERSION.SDK_INT < Build.VERSION_CODES.O || !canDraw(context)) return
        val app = context.applicationContext
        val wm = app.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val sizePx = (72 * app.resources.displayMetrics.density).toInt()
        val params = WindowManager.LayoutParams(
            sizePx,
            sizePx,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = lastX
            y = lastY
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
                setStroke((2 * app.resources.displayMetrics.density).toInt(), Color.WHITE)
            }
            elevation = 8f
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
                    }
                    if (isDragging) {
                        params.x = (initialX + dx).toInt()
                        params.y = (initialY + dy).toInt()
                        lastX = params.x
                        lastY = params.y
                        try {
                            wm.updateViewLayout(bubble, params)
                        } catch (_: Exception) {}
                    }
                    true
                }
                MotionEvent.ACTION_UP -> {
                    handler.removeCallbacks(longPressRunnable)
                    if (!isDragging && !isLongPressed) {
                        onTap()
                    }
                    true
                }
                MotionEvent.ACTION_CANCEL -> {
                    handler.removeCallbacks(longPressRunnable)
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
        val bubble = view ?: return
        val wm = context.applicationContext.getSystemService(Context.WINDOW_SERVICE) as WindowManager
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
