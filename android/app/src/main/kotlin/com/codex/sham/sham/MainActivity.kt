package com.codex.sham.sham

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val widgetChannelName = "com.codex.sham/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, widgetChannelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "refreshWidget" -> {
                    WidgetUpdater.refreshAllWidgets(applicationContext)
                    result.success(null)
                }
                "requestPinWidget" -> {
                    result.success(requestPinWidget())
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun requestPinWidget(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return false
        }

        val manager = AppWidgetManager.getInstance(this)
        if (!manager.isRequestPinAppWidgetSupported) {
            return false
        }

        val componentName = ComponentName(this, HairWashWidgetProvider::class.java)
        return manager.requestPinAppWidget(componentName, null, null)
    }
}
