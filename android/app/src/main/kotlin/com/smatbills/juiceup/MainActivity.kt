package com.smatbills.juiceup

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "jucie_up/ussd"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "dialUssd" -> {
                    val code = call.argument<String>("code")
                    if (code.isNullOrEmpty()) {
                        result.error("INVALID_CODE", "No USSD code provided", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val uri = Uri.parse("tel:" + Uri.encode(code))
                        val intent = Intent(Intent.ACTION_CALL, uri)
                        startActivity(intent)
                        result.success(true)
                    } catch (e: SecurityException) {
                        result.error("PERMISSION_DENIED", "CALL_PHONE permission not granted", null)
                    } catch (e: Exception) {
                        result.error("DIAL_FAILED", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
