package de.bot.glossarium.glossarium

import android.content.Intent
import android.os.Bundle
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.BufferedReader
import java.io.InputStreamReader
import android.provider.OpenableColumns

class MainActivity: FlutterActivity() {

    private val CHANNEL = "glossarium.process.csv"
    private var data: String? = null

    private fun handleCSV(intent: Intent) {
        val uriString = intent.dataString
        val uri = Uri.parse(uriString)
        val cursor = contentResolver.query(uri, null, null, null, null)
        val nameIndex = cursor?.getColumnIndex(OpenableColumns.DISPLAY_NAME)
        cursor?.moveToFirst()
        val name = cursor?.getString(nameIndex!!)
        val inputStream = contentResolver.openInputStream(uri)
        val reader = BufferedReader(InputStreamReader(inputStream))
        data = ""

        reader.useLines { lines ->
            data = lines.filterNot { it.isBlank() }.joinToString("\n")
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val intent = intent
        val action = intent.action
        val type = intent.type

        if (Intent.ACTION_VIEW == action && type != null) {
            if ("text/comma-separated-values" == type) {
                handleCSV(intent)
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method!!.contentEquals("getCSV")) {
                    result.success(data)
                } else {
                    result.notImplemented()
                }
            }
    }
}
