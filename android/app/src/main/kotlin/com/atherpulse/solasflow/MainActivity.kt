package com.atherpulse.solasflow

import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.util.UUID

class MainActivity : FlutterActivity() {
    private companion object {
        const val WIDGET_CHANNEL = "com.atherpulse.solasflow/widget"
        const val AUDIO_CHANNEL = "com.atherpulse.solasflow/audio"
        const val FLUTTER_PREFS = "FlutterSharedPreferences"
        const val ACTION_QUEUE_KEY = "native_widget_action_queue_v1"
    }

    private var widgetChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        window.decorView.setOnWindowFocusChangeListener { hasFocus ->
            if (!hasFocus) return@setOnWindowFocusChangeListener
            applyPendingBrightness()
        }
        widgetChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_CHANNEL)
        widgetChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "updateWidgetState" -> {
                    val state = call.arguments as? Map<*, *>
                    if (state == null) {
                        result.error("invalid_state", "Widget state map is required", null)
                    } else {
                        updateWidgetState(state)
                        result.success(true)
                    }
                }
                "drainWidgetActions" -> result.success(readQueuedActions())
                "ackWidgetAction" -> {
                    val id = call.argument<String>("id")
                    if (id == null) {
                        result.error("missing_id", "Widget action id is required", null)
                    } else {
                        acknowledgeAction(id)
                        result.success(true)
                    }
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUDIO_CHANNEL)
            .setMethodCallHandler { call, result ->
                try {
                    val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                    val max = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
                    if (max <= 0) {
                        result.error("audio_max_zero", "Media max volume unavailable", null)
                        return@setMethodCallHandler
                    }
                    when (call.method) {
                        "getMediaVolumeRatio" -> {
                            val current = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
                            result.success(current.toDouble() / max.toDouble())
                        }
                        "setMediaVolumeRatio" -> {
                            val ratio = call.argument<Double>("ratio")?.coerceIn(0.0, 1.0)
                            if (ratio == null) {
                                result.error("missing_ratio", "ratio is required", null)
                            } else {
                                val target = (ratio * max).toInt().coerceIn(0, max)
                                audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, target, 0)
                                result.success(true)
                            }
                        }
                        else -> result.notImplemented()
                    }
                } catch (error: SecurityException) {
                    result.error("audio_permission_denied", error.message, null)
                } catch (error: Exception) {
                    result.error("audio_failed", error.message, null)
                }
            }
    }


    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        widgetChannel?.invokeMethod("widgetActionsAvailable", null)
    }

    @Synchronized
    private fun readQueuedActions(): List<Map<String, String>> {
        val prefs = getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
        val queue = parseQueue(prefs.getString(ACTION_QUEUE_KEY, null))
        return (0 until queue.length()).mapNotNull { index ->
            val item = queue.optJSONObject(index) ?: return@mapNotNull null
            val id = item.optString("id")
            val action = item.optString("action")
            if (id.isEmpty() || action.isEmpty()) null
            else mapOf(
                "id" to id,
                "action" to action,
                "receivedAtEpochMs" to item.optString("receivedAtEpochMs", "0")
            )
        }
    }

    @Synchronized
    private fun acknowledgeAction(id: String) {
        val prefs = getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
        val queue = parseQueue(prefs.getString(ACTION_QUEUE_KEY, null))
        val remaining = JSONArray()
        for (index in 0 until queue.length()) {
            val item = queue.optJSONObject(index) ?: continue
            if (item.optString("id") != id) remaining.put(item)
        }
        prefs.edit().putString(ACTION_QUEUE_KEY, remaining.toString()).commit()
    }

    private fun parseQueue(raw: String?): JSONArray = try {
        if (raw.isNullOrBlank()) JSONArray() else JSONArray(raw)
    } catch (_: Exception) {
        JSONArray()
    }

    /**
     * Dims the window on the first focus gain after a widget launch.
     *
     * The dim level is a one-shot request from [WidgetActionReceiver]; it is
     * cleared immediately so only the widget-launched window is affected.
     * Flutter re-asserts or releases the same level when the fullscreen clock
     * opens or closes.
     */
    private fun applyPendingBrightness() {
        val prefs = getSharedPreferences("solasflow_native_launch", Context.MODE_PRIVATE)
        val level = prefs.getFloat(
            WidgetActionReceiver.PENDING_BRIGHTNESS_KEY, -1f
        )
        if (level <= 0f) return
        prefs.edit().remove(WidgetActionReceiver.PENDING_BRIGHTNESS_KEY).commit()
        val attributes = window.attributes
        attributes.screenBrightness = level.coerceIn(0.01f, 1f)
        window.attributes = attributes
        android.util.Log.i("SolasFlowWidget", "Launch brightness dimmed to $level")
    }

    private fun updateWidgetState(state: Map<*, *>) {
        val prefs = getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
        prefs.edit()
            .putBoolean("flutter.widget_clock_on", state["clockOn"] as? Boolean ?: false)
            .putBoolean("flutter.widget_timer_speak", state["timerSpeakOn"] as? Boolean ?: true)
            .putBoolean("flutter.widget_stopwatch_speak", state["stopwatchSpeakOn"] as? Boolean ?: true)
            .putBoolean("flutter.widget_goals_on", state["goalReminderOn"] as? Boolean ?: false)
            .putBoolean("flutter.widget_speech_master", state["speechMasterOn"] as? Boolean ?: true)
            .putString("flutter.widget_timer_display", state["timerDisplay"]?.toString() ?: "00:00")
            .putString("flutter.widget_armed_action", state["armedAction"]?.toString() ?: "")
            .commit()
        TimerPresetsWidget.updateAllWidgets(applicationContext)
        SpeechControlsWidget.updateAllWidgets(applicationContext)
        LiveClockWidget.updateAllWidgets(applicationContext)
        FullscreenClockWidget.updateAllWidgets(applicationContext)
    }
}

class WidgetActionReceiver : android.content.BroadcastReceiver() {
    companion object {
        private const val SETTINGS_SNAPSHOT_KEY = "flutter.SettingsSnapshotV9"
        private const val DEFAULT_DIM_LEVEL = 0.08f
        const val PENDING_BRIGHTNESS_KEY = "pending_screen_brightness"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.getStringExtra("widget_action") ?: return
        val allowed = setOf(
            "open_app", "open_clock", "open_fullscreen_clock_direct",
            "toggle_speech_master", "open_fullscreen_clock",
            "start_1m", "start_2m", "start_3m", "start_5m", "start_7m",
            "start_10m", "start_12m", "start_15m", "start_20m", "start_25m",
            "start_30m", "start_35m", "start_45m", "start_60m", "start_90m"
        )
        if (action !in allowed) return
        // Dim before the app window exists so the immersive clock never flashes
        // at full brightness on launch.
        if (action == "open_fullscreen_clock_direct") {
            applyDimmedBrightness(context)
        }
        val prefs = context.getSharedPreferences(
            "FlutterSharedPreferences",
            Context.MODE_PRIVATE
        )
        val queueKey = "native_widget_action_queue_v1"
        val queue = try {
            JSONArray(prefs.getString(queueKey, null) ?: "[]")
        } catch (_: Exception) {
            JSONArray()
        }
        queue.put(
            JSONObject()
                .put("id", UUID.randomUUID().toString())
                .put("action", action)
                .put("receivedAtEpochMs", System.currentTimeMillis())
        )
        prefs.edit().putString(queueKey, queue.toString()).commit()
        context.startActivity(
            Intent(context, MainActivity::class.java).addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            )
        )
    }

    /**
     * Stores the user's saved fullscreen dim preference for this launch.
     *
     * The preference lives inside Flutter's settings snapshot JSON. It is only
     * stored when the user has dimming enabled, so the app otherwise keeps its
     * current screen brightness behaviour untouched.
     */
    private fun applyDimmedBrightness(context: Context) {
        val prefs = context.getSharedPreferences(
            "FlutterSharedPreferences",
            Context.MODE_PRIVATE
        )
        val snapshot = prefs.getString(SETTINGS_SNAPSHOT_KEY, null)
        val launchPrefs = context.getSharedPreferences(
            "solasflow_native_launch",
            Context.MODE_PRIVATE
        )
        var level: Float? = null
        if (!snapshot.isNullOrBlank()) {
            try {
                val json = JSONObject(snapshot)
                if (json.optBoolean("fullscreenDimBrightness", false)) {
                    level = json.optDouble(
                        "fullscreenDimBrightnessLevel",
                        DEFAULT_DIM_LEVEL.toDouble()
                    ).toFloat().coerceIn(0.01f, 1f)
                }
            } catch (error: Exception) {
                android.util.Log.w("SolasFlowWidget", "Dim preference read failed", error)
            }
        }
        if (level != null) {
            launchPrefs.edit().putFloat(PENDING_BRIGHTNESS_KEY, level).commit()
        } else {
            launchPrefs.edit().remove(PENDING_BRIGHTNESS_KEY).commit()
        }
    }
}
