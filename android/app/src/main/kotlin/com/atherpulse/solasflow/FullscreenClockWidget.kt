package com.atherpulse.solasflow

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

/**
 * Widget: Fullscreen Clock tile
 *
 * A compact tile that opens the immersive fullscreen clock directly.
 * Wide layouts fold a "Dim" button into the tile body; narrow layouts keep
 * the tile a single large tap target.
 */
class FullscreenClockWidget : AppWidgetProvider() {

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
        private const val MAX_WIDE_DP = 160
        private const val ACTION_IMMEDIATE = "open_fullscreen_clock_direct"

        fun updateAllWidgets(context: Context) {
            val mgr = AppWidgetManager.getInstance(context)
            val ids = mgr.getAppWidgetIds(
                ComponentName(context, FullscreenClockWidget::class.java)
            )
            for (id in ids) updateWidget(context, mgr, id)
        }

        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val wide = isWide(appWidgetManager, appWidgetId)
            val layout = if (wide) R.layout.widget_fullscreen_clock_wide
            else R.layout.widget_fullscreen_clock

            val views = RemoteViews(context.packageName, layout)
            val openIntent = makeActionIntent(
                context, ACTION_IMMEDIATE, appWidgetId, 1
            )
            views.setOnClickPendingIntent(R.id.fs_clock_root, openIntent)

            // The wide layout's extra Dim button reuses the tile body's intent,
            // so a tap anywhere still lands in the immersive clock.
            if (wide) {
                views.setOnClickPendingIntent(R.id.fs_clock_dim, openIntent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun isWide(
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ): Boolean {
            val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
            val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
            val maxWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_WIDTH)
            val dp = if (minWidth > 0) minWidth else maxWidth
            return dp >= MAX_WIDE_DP
        }

        private fun makeActionIntent(
            context: Context,
            action: String,
            widgetId: Int,
            slot: Int
        ): PendingIntent {
            val intent = Intent(context, WidgetActionReceiver::class.java).apply {
                putExtra("widget_action", action)
            }
            return PendingIntent.getBroadcast(
                context,
                (action.hashCode() and 0xFFFF) or (widgetId shl 16) or (slot and 0xF),
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }
    }
}