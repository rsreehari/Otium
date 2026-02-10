package com.example.otium

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * MainActivity with Otium Intervention Overlay support.
 * 
 * Provides platform channel for:
 * - Checking/requesting overlay permission
 * - Showing full-screen breathing intervention overlay
 * - Managing foreground service for persistence
 */
class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.otium/intervention"
    private val OVERLAY_PERMISSION_REQUEST_CODE = 1234

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkOverlayPermission" -> {
                    result.success(hasOverlayPermission())
                }
                "requestOverlayPermission" -> {
                    requestOverlayPermission()
                    result.success(null)
                }
                "showIntervention" -> {
                    if (hasOverlayPermission()) {
                        showInterventionOverlay()
                        result.success(true)
                    } else {
                        result.error("PERMISSION_DENIED", "Overlay permission not granted", null)
                    }
                }
                "hideIntervention" -> {
                    hideInterventionOverlay()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun hasOverlayPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true
        }
    }

    private fun requestOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )
            startActivityForResult(intent, OVERLAY_PERMISSION_REQUEST_CODE)
        }
    }

    private fun showInterventionOverlay() {
        val intent = Intent(this, InterventionOverlayService::class.java)
        intent.action = InterventionOverlayService.ACTION_SHOW
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    private fun hideInterventionOverlay() {
        val intent = Intent(this, InterventionOverlayService::class.java)
        intent.action = InterventionOverlayService.ACTION_HIDE
        startService(intent)
    }
}
