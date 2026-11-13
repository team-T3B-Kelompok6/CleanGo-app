package com.example.cleango_app

import android.Manifest.permission as perm
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Location
import android.net.Uri
import android.provider.Settings
import android.location.LocationManager
import android.os.Bundle
import android.os.CancellationSignal
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import androidx.core.content.ContextCompat
import androidx.core.location.LocationManagerCompat
import androidx.core.util.Consumer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private lateinit var locationManager: LocationManager
    private lateinit var locationChannel: MethodChannel
    private lateinit var permissionsChannel: MethodChannel
    private var pendingLocationResult: MethodChannel.Result? = null
    private var pendingRequestCode = -1
    private var pendingCameraResult: MethodChannel.Result? = null
    private var pendingCameraRequestCode = -1
    private var pendingLocationToken = 0
    private var locationTokenCounter = 0
    private var locationRequestInProgress = false
    private var pendingCancellationSignal: CancellationSignal? = null
    private var pendingTimeoutRunnable: Runnable? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    companion object {
        private const val REQUEST_LOCATION_PERMISSIONS = 1001
        private const val REQUEST_CAMERA_PERMISSION = 1002
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        PushNotificationChannel.handleIntent(intent, deliver = false)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        PushNotificationChannel.handleIntent(intent)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        PushNotificationChannel.register(this, flutterEngine)
        locationChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.cleango.app/location")
        locationChannel.setMethodCallHandler { call, result ->
            if (call.method == "getCurrentLocation") {
                if (locationRequestInProgress || pendingLocationResult != null) {
                    result.error("location_request_in_progress", "Permintaan lokasi masih berlangsung.", null)
                    return@setMethodCallHandler
                }
                val token = ++locationTokenCounter
                pendingRequestCode = REQUEST_LOCATION_PERMISSIONS
                pendingLocationToken = token
                pendingLocationResult = result
                val fineGranted = PackageManager.PERMISSION_GRANTED ==
                    checkSelfPermission(perm.ACCESS_FINE_LOCATION)
                val coarseGranted = PackageManager.PERMISSION_GRANTED ==
                    checkSelfPermission(perm.ACCESS_COARSE_LOCATION)
                if (!fineGranted && !coarseGranted) {
                    requestPermissions(arrayOf(perm.ACCESS_FINE_LOCATION, perm.ACCESS_COARSE_LOCATION), REQUEST_LOCATION_PERMISSIONS)
                } else {
                    fetchLocation(result, token)
                }
            } else {
                result.notImplemented()
            }
        }
        permissionsChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.cleango.app/permissions")
        permissionsChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "requestCameraPermission" -> {
                    if (pendingCameraResult != null) {
                        result.error("camera_request_in_progress", "Permintaan kamera masih berlangsung.", null)
                        return@setMethodCallHandler
                    }
                    pendingCameraResult = result
                    pendingCameraRequestCode = REQUEST_CAMERA_PERMISSION
                    if (ContextCompat.checkSelfPermission(this, perm.CAMERA) == PackageManager.PERMISSION_GRANTED) {
                        finishCamera(result, "granted")
                    } else {
                        requestPermissions(arrayOf(perm.CAMERA), REQUEST_CAMERA_PERMISSION)
                    }
                }
                "openAppSettings" -> {
                    openAppSettings()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_CAMERA_PERMISSION) {
            val result = pendingCameraResult ?: return
            pendingCameraResult = null
            pendingCameraRequestCode = -1
            val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
            if (granted) {
                finishCamera(result, "granted")
            } else if (shouldShowRequestPermissionRationale(perm.CAMERA)) {
                finishCamera(result, "denied")
            } else {
                finishCamera(result, "permanently_denied")
            }
            return
        }
        if (requestCode != REQUEST_LOCATION_PERMISSIONS) return
        if (requestCode != pendingRequestCode) return
        val result = pendingLocationResult ?: return
        val token = pendingLocationToken
        if (token == 0) return
        val fineGranted = PackageManager.PERMISSION_GRANTED == checkSelfPermission(perm.ACCESS_FINE_LOCATION)
        val coarseGranted = PackageManager.PERMISSION_GRANTED == checkSelfPermission(perm.ACCESS_COARSE_LOCATION)
        if (!fineGranted && !coarseGranted) {
            finishLocation(result, token, null, "permission_denied", "Izin lokasi ditolak. Aktifkan di pengaturan aplikasi.")
            return
        }
        fetchLocation(result, token)
    }

    override fun onDestroy() {
        val cameraResult = pendingCameraResult
        if (cameraResult != null) {
            try {
                cameraResult.error("camera_cancelled", "Permintaan kamera dibatalkan.", null)
            } catch (_: Exception) {
            }
            pendingCameraResult = null
            pendingCameraRequestCode = -1
        }
        val result = pendingLocationResult
        val token = pendingLocationToken
        if (result != null && token != 0) {
            try {
                finishLocation(result, token, null, "location_cancelled", "Permintaan lokasi dibatalkan.")
            } catch (_: Exception) {
            }
        } else {
            pendingTimeoutRunnable?.let { mainHandler.removeCallbacks(it) }
            pendingCancellationSignal?.cancel()
            pendingTimeoutRunnable = null
            pendingCancellationSignal = null
        }
        super.onDestroy()
    }

    private fun finishLocation(
        result: MethodChannel.Result,
        token: Int,
        data: Map<String, Any>? = null,
        errorCode: String? = null,
        errorMessage: String? = null
    ) {
        if (pendingLocationResult !== result || pendingLocationToken != token) return
        pendingTimeoutRunnable?.let { mainHandler.removeCallbacks(it) }
        pendingTimeoutRunnable = null
        pendingCancellationSignal?.cancel()
        pendingCancellationSignal = null
        pendingLocationResult = null
        pendingRequestCode = -1
        pendingLocationToken = 0
        locationRequestInProgress = false
        when {
            data != null -> result.success(data)
            errorCode != null -> result.error(errorCode, errorMessage ?: "", null)
            else -> result.error("location_timeout", "Lokasi tidak dapat ditemukan dalam waktu yang ditentukan.", null)
        }
    }

    private fun finishCamera(result: MethodChannel.Result, status: String) {
        pendingCameraResult = null
        pendingCameraRequestCode = -1
        result.success(status)
    }

    private fun openAppSettings() {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        intent.data = Uri.parse("package:${packageName}")
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    private fun fetchLocation(result: MethodChannel.Result, token: Int) {
        val fineGranted = PackageManager.PERMISSION_GRANTED == checkSelfPermission(perm.ACCESS_FINE_LOCATION)
        val coarseGranted = PackageManager.PERMISSION_GRANTED == checkSelfPermission(perm.ACCESS_COARSE_LOCATION)
        val provider = if (fineGranted) {
            when {
                locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER) -> LocationManager.GPS_PROVIDER
                locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER) -> LocationManager.NETWORK_PROVIDER
                else -> null
            }
        } else if (coarseGranted) {
            if (locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)) {
                LocationManager.NETWORK_PROVIDER
            } else {
                null
            }
        } else {
            null
        }

        if (provider == null) {
            finishLocation(result, token, null, "location_unavailable", "Lokasi tidak aktif atau tidak dapat ditemukan.")
            return
        }

        locationRequestInProgress = true
        val cancellationSignal = CancellationSignal()
        pendingCancellationSignal = cancellationSignal
        val timeoutRunnable = Runnable {
            if (pendingLocationResult === result && pendingLocationToken == token && locationRequestInProgress) {
                finishLocation(result, token, null, "location_timeout", "Lokasi tidak dapat ditemukan dalam waktu yang ditentukan.")
            }
        }
        pendingTimeoutRunnable = timeoutRunnable
        mainHandler.postDelayed(timeoutRunnable, 10000)

        try {
            LocationManagerCompat.getCurrentLocation(
                locationManager,
                provider,
                cancellationSignal,
                ContextCompat.getMainExecutor(this),
                object : Consumer<Location?> {
                    override fun accept(location: Location?) {
                        if (location == null) {
                            finishLocation(result, token, null, "location_unavailable", "Lokasi tidak dapat ditemukan.")
                        } else {
                            finishLocation(result, token, mapOf("latitude" to location.latitude, "longitude" to location.longitude))
                        }
                    }
                }
            )
        } catch (e: SecurityException) {
            finishLocation(result, token, null, "permission_denied", "Izin lokasi ditolak. Aktifkan di pengaturan aplikasi.")
        } catch (e: Exception) {
            finishLocation(result, token, null, "location_unavailable", "Lokasi tidak aktif atau tidak dapat ditemukan.")
        }
    }
}
