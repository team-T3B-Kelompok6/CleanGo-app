package com.example.cleango_app

import android.Manifest
import android.app.Activity
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// Native Android notifications avoid adding a second Flutter messaging package.
object PushNotificationChannel {
    private const val CHANNEL_ID = "cleango_orders"
    private const val TAP_DATA = "cleango_push_data"
    private var channel: MethodChannel? = null
    private var initialTap: Map<String, String>? = null

    fun handleIntent(intent: Intent, deliver: Boolean = true) {
        val json = intent.getStringExtra(TAP_DATA) ?: return
        intent.removeExtra(TAP_DATA)
        val data = try {
            val obj = org.json.JSONObject(json)
            obj.keys().asSequence().associateWith { obj.getString(it) }
        } catch (_: Exception) { return }
        if (deliver && channel != null) channel?.invokeMethod("tap", data)
        else initialTap = data
    }

    fun register(activity: Activity, engine: FlutterEngine) {
        handleIntent(activity.intent, deliver = false)
        val manager = activity.getSystemService(NotificationManager::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            manager.createNotificationChannel(NotificationChannel(
                CHANNEL_ID, "Pesanan CleanGo", NotificationManager.IMPORTANCE_HIGH
            ))
        }
        channel = MethodChannel(engine.dartExecutor.binaryMessenger, "com.cleango.app/push")
        channel!!.setMethodCallHandler { call, result ->
                if (call.method == "initialTap") {
                    result.success(initialTap)
                    initialTap = null
                    return@setMethodCallHandler
                }
                if (call.method != "show") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
                    activity.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                    result.success(null)
                    return@setMethodCallHandler
                }
                val title = call.argument<String>("title")?.take(200) ?: "CleanGo"
                val body = call.argument<String>("body")?.take(2000) ?: ""
                val data = call.argument<Map<String, String>>("data") ?: emptyMap()
                val id = (data["notificationId"] ?: data["bookingId"] ?: "cleango").hashCode()
                val intent = Intent(activity, activity.javaClass).apply {
                    flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    putExtra(TAP_DATA, org.json.JSONObject(data).toString())
                }
                val pendingIntent = PendingIntent.getActivity(
                    activity, id, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    Notification.Builder(activity, CHANNEL_ID)
                } else {
                    @Suppress("DEPRECATION")
                    Notification.Builder(activity).setPriority(Notification.PRIORITY_HIGH)
                }
                val notification = builder
                    .setSmallIcon(R.drawable.ic_notification)
                    .setContentTitle(title)
                    .setContentText(body)
                    .setStyle(Notification.BigTextStyle().bigText(body))
                    .setContentIntent(pendingIntent)
                    .setAutoCancel(true)
                    .setVisibility(Notification.VISIBILITY_PRIVATE)
                    .build()
                try {
                    manager.notify(id, notification)
                    result.success(null)
                } catch (_: SecurityException) {
                    result.success(null)
                }
            }
    }
}
