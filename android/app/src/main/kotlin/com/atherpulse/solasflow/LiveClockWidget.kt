package com.atherpulse.solasflow

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

/**
 * Widget: Live Realtime Clock
 *
 * Displays current wall-clock time with seconds ticking live in real-time.
 * Uses Android's native TextClock which updates natively inside the Launcher/SystemUI
 * process without battery-draining background alarms or polling services.
 */
class LiveClockWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateAllWidgets(context: Context) {
            val mgr = AppWidgetManager.getInstance(context)
            val ids = mgr.getAppWidgetIds(
                ComponentName(context, LiveClockWidget::class.java)
            )
            for (id in ids) {
                updateWidget(context, mgr, id)
            }
        }

        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.widget_live_clock)

            // Tapping the widget body, clock, title, or "Open Clock" button opens the Clock tab
            val openClockIntent = makeActionIntent(context, "open_clock", appWidgetId, 1)
            views.setOnClickPendingIntent(R.id.widget_clock_container, openClockIntent)
            views.setOnClickPendingIntent(R.id.live_text_clock, openClockIntent)
            views.setOnClickPendingIntent(R.id.widget_title, openClockIntent)
            views.setOnClickPendingIntent(R.id.btn_open_clock, openClockIntent)

            // Tapping "Focus Mode" directly opens the fullscreen immersive clock
            val focusIntent = makeActionIntent(context, "open_fullscreen_clock_direct", appWidgetId, 2)
            views.setOnClickPendingIntent(R.id.btn_fullscreen_clock, focusIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun makeActionIntent(
            context: Context,
            action: String,
            widgetId: Int,
            slot: Int
        ): PendingIntent {
            val intent = Intent(context, MainActivity::class.java).apply {
                putExtra("widget_action", action)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            return PendingIntent.getActivity(
                context,
                (action.hashCode() and 0xFFFF) or (widgetId shl 16) or (slot and 0xF),
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }
    }
}
