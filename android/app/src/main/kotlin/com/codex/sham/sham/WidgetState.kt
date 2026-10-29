package com.codex.sham.sham

import android.content.Context
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import java.util.TimeZone
import kotlin.math.abs

data class WidgetState(
    val title: String,
    val status: String,
    val nextDateLine: String,
    val setupHint: String? = null,
)

object WidgetStateReader {
    private const val PREF_FILE = "FlutterSharedPreferences"
    private const val PREFIX = "flutter."
    private const val KEY_TITLE = PREFIX + "widgetTitle"
    private const val KEY_INTERVAL = PREFIX + "washIntervalDays"
    private const val KEY_LAST_WASH = PREFIX + "lastWashDate"
    private const val DEFAULT_INTERVAL_DAYS = 3
    private const val INPUT_PATTERN = "yyyy-MM-dd"
    private const val OUTPUT_PATTERN = "yyyy-MM-dd"

    fun read(context: Context): WidgetState {
        val prefs = context.getSharedPreferences(PREF_FILE, Context.MODE_PRIVATE)
        val title = prefs.getString(KEY_TITLE, null)
            ?.trim()
            ?.takeIf { it.isNotEmpty() }
            ?: context.getString(R.string.widget_title_default)
        val intervalDays = prefs.getInt(KEY_INTERVAL, DEFAULT_INTERVAL_DAYS).coerceIn(1, 14)
        val lastWashRaw = prefs.getString(KEY_LAST_WASH, null)
            ?.trim()
            ?.takeIf { it.isNotEmpty() }

        if (lastWashRaw == null) {
            return WidgetState(
                title = title,
                status = context.getString(R.string.widget_status_setup),
                nextDateLine = context.getString(R.string.widget_next_setup),
                setupHint = context.getString(R.string.widget_hint_setup),
            )
        }

        val lastWashDate = parseDate(lastWashRaw)
            ?: return WidgetState(
                title = title,
                status = context.getString(R.string.widget_status_invalid),
                nextDateLine = context.getString(R.string.widget_next_invalid),
                setupHint = context.getString(R.string.widget_hint_invalid),
            )

        val nextWashDate = shiftDays(lastWashDate, intervalDays)
        val daysDiff = daysBetween(todayDate(), nextWashDate)
        return WidgetState(
            title = title,
            status = statusFor(context, daysDiff),
            nextDateLine = context.getString(R.string.widget_next_date_line, formatDate(nextWashDate)),
            setupHint = null,
        )
    }

    private fun statusFor(context: Context, daysDiff: Int): String {
        return when {
            daysDiff == 0 -> context.getString(R.string.widget_status_today)
            daysDiff == 1 -> context.getString(R.string.widget_status_tomorrow)
            daysDiff > 1 -> context.getString(R.string.widget_status_in_days, daysDiff)
            daysDiff == -1 -> context.getString(R.string.widget_status_overdue_one)
            else -> context.getString(R.string.widget_status_overdue, abs(daysDiff))
        }
    }

    private fun todayDate(): Date = Date()

    private fun parseDate(raw: String): Date? {
        return try {
            dateFormat(INPUT_PATTERN).parse(raw)
        } catch (_: Exception) {
            null
        }
    }

    private fun formatDate(date: Date): String {
        return dateFormat(OUTPUT_PATTERN).format(date)
    }

    private fun shiftDays(date: Date, days: Int): Date {
        val calendar = calendarFor(date)
        calendar.add(Calendar.DAY_OF_YEAR, days)
        return calendar.time
    }

    private fun daysBetween(startDate: Date, endDate: Date): Int {
        val start = calendarFor(startDate)
        val end = calendarFor(endDate)
        return julianDay(end) - julianDay(start)
    }

    private fun calendarFor(date: Date): Calendar {
        return Calendar.getInstance().apply {
            time = date
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
    }

    private fun julianDay(calendar: Calendar): Int {
        val year = calendar.get(Calendar.YEAR)
        val month = calendar.get(Calendar.MONTH) + 1
        val day = calendar.get(Calendar.DAY_OF_MONTH)
        val adjust = (14 - month) / 12
        val adjustedYear = year + 4800 - adjust
        val adjustedMonth = month + 12 * adjust - 3
        val value =
            day + ((153L * adjustedMonth + 2L) / 5L) +
                365L * adjustedYear +
                adjustedYear / 4L -
                adjustedYear / 100L +
                adjustedYear / 400L -
                32045L
        return value.toInt()
    }

    private fun dateFormat(pattern: String): SimpleDateFormat {
        return SimpleDateFormat(pattern, Locale.getDefault()).apply {
            isLenient = false
            timeZone = TimeZone.getDefault()
        }
    }
}
