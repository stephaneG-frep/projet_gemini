package com.example.focus_buddy

import android.media.AudioManager
import android.media.ToneGenerator
import android.speech.tts.TextToSpeech
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity : FlutterActivity(), TextToSpeech.OnInitListener {
    private val channelName = "focus_buddy/audio"
    private var textToSpeech: TextToSpeech? = null
    private var ttsReady = false
    private var pendingMessage: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        textToSpeech = TextToSpeech(this, this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler {
            call,
            result ->
            when (call.method) {
                "sessionComplete" -> {
                    val message = call.argument<String>("message")
                        ?: "Bravo, session terminee. Continue comme ca."
                    playSuccessTone()
                    speak(message)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            val languageResult = textToSpeech?.setLanguage(Locale.FRANCE)
            ttsReady = languageResult != TextToSpeech.LANG_MISSING_DATA &&
                languageResult != TextToSpeech.LANG_NOT_SUPPORTED
            pendingMessage?.let {
                speak(it)
                pendingMessage = null
            }
        }
    }

    override fun onDestroy() {
        textToSpeech?.stop()
        textToSpeech?.shutdown()
        textToSpeech = null
        super.onDestroy()
    }

    private fun playSuccessTone() {
        try {
            val tone = ToneGenerator(AudioManager.STREAM_NOTIFICATION, 80)
            tone.startTone(ToneGenerator.TONE_PROP_ACK, 180)
            window.decorView.postDelayed({ tone.release() }, 320)
        } catch (_: RuntimeException) {
        }
    }

    private fun speak(message: String) {
        if (!ttsReady) {
            pendingMessage = message
            return
        }

        textToSpeech?.speak(message, TextToSpeech.QUEUE_FLUSH, null, "focus-session-complete")
    }
}
