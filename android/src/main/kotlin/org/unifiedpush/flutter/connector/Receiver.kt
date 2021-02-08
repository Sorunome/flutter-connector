package org.unifiedpush.flutter.connector

import android.content.Context
import android.content.Intent
import android.os.Handler
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.view.FlutterMain
import io.flutter.embedding.engine.dart.DartExecutor.DartEntrypoint
import org.unifiedpush.android.connector.MessagingReceiverHandler


abstract class UnifiedPushService : MessagingReceiverHandler {
    abstract fun getEngine(context: Context): FlutterEngine

    private val handler = Handler()

    private fun getPlugin(context: Context): Plugin {
        val registry = getEngine(context).getPlugins()
        var plugin = registry.get(Plugin::class.java) as? Plugin
        if (plugin == null) {
            plugin = Plugin()
            registry.add(plugin)
        }
        return plugin;
    }

    override fun onMessage(context: Context?, message: String) {
        Log.d("Receiver","OnMessage")
        handler.post {
            getPlugin(context!!).channel?.invokeMethod("onMessage", message)
        }
    }

    override fun onNewEndpoint(context: Context?, endpoint: String) {
        Log.d("Receiver","OnNewEndpoint")
        handler.post {
            getPlugin(context!!).channel?.invokeMethod("onNewEndpoint", endpoint)
        }
    }

    override fun onRegistrationFailed(context: Context?) {
        handler.post {
            getPlugin(context!!).channel?.invokeMethod("onRegistrationFailed", null)
        }
    }

    override fun onRegistrationRefused(context: Context?) {
        Log.d("Receiver","OnRegistrationRefused")
        handler.post {
            getPlugin(context!!).channel?.invokeMethod("onRegistrationRefused", null)
        }
    }

    override fun onUnregistered(context: Context?) {
        Log.d("Receiver","OnUnregistered")
        handler.post {
            getPlugin(context!!).channel?.invokeMethod("onUnregistered", null)
        }
    }
}
