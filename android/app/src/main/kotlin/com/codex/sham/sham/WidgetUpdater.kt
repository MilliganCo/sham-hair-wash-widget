package com.codex.sham.sham

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.view.View
import android.widget.RemoteViews

object WidgetUpdater {
    private const val TITLE_PREFIX = "profile :: "

    fun refreshAllWidgets(context: Context) {
        val manager = AppWidgetManager.getInstance(context)
        val componentName = ComponentName(context, HairWashWidgetProvider::class.java)
        val widgetIds = manager.getAppWidgetIds(componentName)
        if (widgetIds.isNotEmpty()) {
            updateWidgets(context, manager, widgetIds)
        }
    }

    fun updateWidgets(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        val state = WidgetStateReader.read(context)
        val views = RemoteViews(context.packageName, R.layout.hair_wash_widget)
        val openAppPendingIntent = createOpenAppPendingIntent(context)

        views.setTextViewText(R.id.widgetTitle, TITLE_PREFIX + state.title)
        views.setTextViewText(R.id.widgetStatus, state.status)
        views.setTextViewText(R.id.widgetNextDate, state.nextDateLine)
        views.setTextViewText(R.id.widgetHint, state.setupHint ?: "")
        views.setViewVisibility(
            R.id.widgetHint,
            if (state.setupHint.isNullOrBlank()) View.GONE else View.VISIBLE,
        )
        views.setOnClickPendingIntent(R.id.widgetRoot, openAppPendingIntent)

        appWidgetManager.updateAppWidget(appWidgetIds, views)
    }

    private fun createOpenAppPendingIntent(context: Context): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or pendingIntentImmutableFlag()
        return PendingIntent.getActivity(context, 0, intent, flags)
    }

    private fun pendingIntentImmutableFlag(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_IMMUTABLE
        } else {
            0
        }
    }
}
