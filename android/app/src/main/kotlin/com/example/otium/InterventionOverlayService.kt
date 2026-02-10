package com.example.otium

import android.app.*
import android.content.Context
import android.content.Intent
import android.graphics.*
import android.os.Build
import android.os.IBinder
import android.view.*
import android.view.animation.AccelerateDecelerateInterpolator
import android.animation.ValueAnimator
import androidx.core.app.NotificationCompat

/**
 * InterventionOverlayService: Full-screen breathing intervention overlay.
 * 
 * Design Philosophy (from Otium):
 * - Appear OVER current activity, not replace it
 * - Non-judgmental, calm aesthetic
 * - Breathing-aligned pulsing circle
 * - Single tap to dismiss (respect user agency)
 * 
 * Technical Implementation:
 * - Uses SYSTEM_ALERT_WINDOW permission
 * - Runs as foreground service for persistence
 * - Custom breathing animation (4s inhale, 4s exhale)
 */
class InterventionOverlayService : Service() {

    companion object {
        const val ACTION_SHOW = "com.otium.intervention.SHOW"
        const val ACTION_HIDE = "com.otium.intervention.HIDE"
        private const val NOTIFICATION_ID = 1001
        private const val CHANNEL_ID = "otium_intervention_channel"
    }

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var breathingAnimator: ValueAnimator? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_SHOW -> showOverlay()
            ACTION_HIDE -> hideOverlay()
        }
        return START_NOT_STICKY
    }

    private fun showOverlay() {
        if (overlayView != null) return

        // Start as foreground service
        val notification = createNotification()
        startForeground(NOTIFICATION_ID, notification)

        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager

        // Create breathing overlay view
        overlayView = BreathingOverlayView(this).apply {
            setOnClickListener {
                // Respect user agency: single tap dismisses
                hideOverlay()
            }
        }

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        )
        params.gravity = Gravity.CENTER

        windowManager?.addView(overlayView, params)
        startBreathingAnimation()
    }

    private fun hideOverlay() {
        breathingAnimator?.cancel()
        overlayView?.let {
            windowManager?.removeView(it)
        }
        overlayView = null
        stopForeground(true)
        stopSelf()
    }

    private fun startBreathingAnimation() {
        breathingAnimator = ValueAnimator.ofFloat(0f, 1f).apply {
            duration = 8000 // Full breath cycle: 4s in, 4s out
            repeatCount = ValueAnimator.INFINITE
            repeatMode = ValueAnimator.RESTART
            interpolator = AccelerateDecelerateInterpolator()
            addUpdateListener { animator ->
                (overlayView as? BreathingOverlayView)?.setBreathingPhase(animator.animatedValue as Float)
            }
            start()
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Otium Intervention",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Active during cognitive regulation"
                setShowBadge(false)
            }
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        val pendingIntent = PendingIntent.getActivity(
            this, 0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Breathe")
            .setContentText("Tap overlay to return when ready")
            .setSmallIcon(android.R.drawable.ic_menu_info_details)
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    override fun onDestroy() {
        hideOverlay()
        super.onDestroy()
    }
}

/**
 * Custom View for breathing animation overlay.
 * 
 * Visual Design:
 * - Soft blue-grey background (calming, not alarming)
 * - Pulsing circle that expands/contracts with breath
 * - Subtle "Breathe" text that fades with rhythm
 * - Tap anywhere to dismiss (shown as hint)
 */
class BreathingOverlayView(context: Context) : View(context) {

    private var breathingPhase = 0f
    private val circlePaint = Paint(Paint.ANTI_ALIAS_FLAG)
    private val textPaint = Paint(Paint.ANTI_ALIAS_FLAG)
    private val hintPaint = Paint(Paint.ANTI_ALIAS_FLAG)

    init {
        circlePaint.style = Paint.Style.FILL
        
        textPaint.color = Color.WHITE
        textPaint.textAlign = Paint.Align.CENTER
        textPaint.textSize = 48f
        textPaint.typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)

        hintPaint.color = Color.argb(100, 255, 255, 255)
        hintPaint.textAlign = Paint.Align.CENTER
        hintPaint.textSize = 28f
    }

    fun setBreathingPhase(phase: Float) {
        breathingPhase = phase
        invalidate()
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)

        val centerX = width / 2f
        val centerY = height / 2f

        // Soft blue-grey background
        canvas.drawColor(Color.argb(240, 55, 71, 79))

        // Breathing calculation: 0-0.5 = inhale (expand), 0.5-1 = exhale (contract)
        val breathCycle = if (breathingPhase < 0.5f) {
            breathingPhase * 2 // 0 to 1 during inhale
        } else {
            1 - ((breathingPhase - 0.5f) * 2) // 1 to 0 during exhale
        }

        // Circle radius: 80-180 based on breath
        val minRadius = 80f
        val maxRadius = 180f
        val radius = minRadius + (maxRadius - minRadius) * breathCycle

        // Circle color: subtle pulse between two calm tones
        val baseColor = Color.argb(180, 100, 140, 160)
        val accentColor = Color.argb(200, 120, 160, 180)
        circlePaint.color = blendColors(baseColor, accentColor, breathCycle)

        canvas.drawCircle(centerX, centerY, radius, circlePaint)

        // Text opacity follows breathing
        textPaint.alpha = (150 + 105 * breathCycle).toInt()
        val breathText = if (breathingPhase < 0.5f) "Breathe in..." else "Breathe out..."
        canvas.drawText(breathText, centerX, centerY + 8, textPaint)

        // Hint at bottom
        canvas.drawText("Tap anywhere to return", centerX, height - 80f, hintPaint)
    }

    private fun blendColors(color1: Int, color2: Int, ratio: Float): Int {
        val inverseRatio = 1f - ratio
        val r = (Color.red(color1) * inverseRatio + Color.red(color2) * ratio).toInt()
        val g = (Color.green(color1) * inverseRatio + Color.green(color2) * ratio).toInt()
        val b = (Color.blue(color1) * inverseRatio + Color.blue(color2) * ratio).toInt()
        val a = (Color.alpha(color1) * inverseRatio + Color.alpha(color2) * ratio).toInt()
        return Color.argb(a, r, g, b)
    }
}
