package com.yaumi.qurantafsir.id

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Home-screen prayer times widget. Pure renderer: all prayer-time computation
 * stays in Dart (PrayerTimesService), which saves display-ready strings via
 * the home_widget plugin (keys defined in lib/shared/utils/prayer_times_widget.dart)
 * and triggers this provider. Tapping the widget opens the app.
 */
class PrayerTimesWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_prayer_times)

            views.setTextViewText(R.id.widget_date, widgetData.getString("ptw_date", "") ?: "")
            views.setTextViewText(R.id.widget_city, widgetData.getString("ptw_city", "") ?: "")

            val hasData = widgetData.getString("ptw_has_data", "false") == "true"
            if (hasData) {
                views.setViewVisibility(R.id.widget_times_row, View.VISIBLE)
                views.setViewVisibility(R.id.widget_empty, View.GONE)
                bindTime(views, R.id.widget_time_fajr, widgetData, "ptw_fajr")
                bindTime(views, R.id.widget_time_dhuhr, widgetData, "ptw_dhuhr")
                bindTime(views, R.id.widget_time_ashr, widgetData, "ptw_ashr")
                bindTime(views, R.id.widget_time_magrib, widgetData, "ptw_magrib")
                bindTime(views, R.id.widget_time_isya, widgetData, "ptw_isya")
            } else {
                views.setViewVisibility(R.id.widget_times_row, View.GONE)
                views.setViewVisibility(R.id.widget_empty, View.VISIBLE)
            }

            // Tap anywhere on the widget -> open the app.
            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            if (launchIntent != null) {
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    launchIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                )
                views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun bindTime(
        views: RemoteViews,
        viewId: Int,
        widgetData: SharedPreferences,
        key: String,
    ) {
        views.setTextViewText(viewId, widgetData.getString(key, "--:--") ?: "--:--")
    }
}
