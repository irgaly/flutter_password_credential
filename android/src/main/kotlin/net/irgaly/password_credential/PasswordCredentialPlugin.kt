package net.irgaly.password_credential

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import kotlinx.serialization.UnstableDefault
import kotlinx.serialization.json.Json
import net.irgaly.password_credential.entity.Mediation
import net.irgaly.password_credential.entity.PasswordCredential
import kotlin.coroutines.CoroutineContext

@Suppress("unused")
class PasswordCredentialPlugin : FlutterPlugin, MethodCallHandler, CoroutineScope {
    private lateinit var channel: MethodChannel
    private lateinit var job: Job
    override val coroutineContext: CoroutineContext get() = job + Dispatchers.Default

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        job = Job()
        channel = MethodChannel(flutterPluginBinding.flutterEngine.dartExecutor, "password_credential").apply {
            setMethodCallHandler(this@PasswordCredentialPlugin)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        job.cancel()
    }

    @OptIn(UnstableDefault::class)
    override fun onMethodCall(call: MethodCall, result: Result) {
        launch {
            try {
                when (call.method) {
                    "hasCredentialFeature" -> result.success(hasCredentialFeature())
                    "get" -> {
                        val mediation = call.argument<String>("mediation")?.let {
                            Json.parse(Mediation.serializer(), it)
                        } ?: Mediation.Silent
                        val ret = get(mediation)?.let {
                            Json.stringify(PasswordCredential.serializer(), it)
                        }
                        result.success(ret)
                    }
                    "store" -> {
                        val credential = call.argument<String>("credential")?.let {
                            Json.parse(PasswordCredential.serializer(), it)
                        } ?: throw IllegalArgumentException("credential is null")
                        store(credential)
                        result.success(null)
                    }
                    "delete" -> {
                        val id = call.argument<String>("id") ?: throw IllegalArgumentException("id is null")
                        delete(id)
                        result.success(null)
                    }
                    "preventSilentAccess" -> {
                        preventSilentAccess()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Throwable) {
                result.error(e.javaClass.name, e.message, e.stackTrace)
            }
        }
    }

    private suspend fun get(mediation: Mediation): PasswordCredential? {
        throw NotImplementedError()
    }

    private suspend fun store(credential: PasswordCredential) {
        throw NotImplementedError()
    }

    private suspend fun delete(id: String) {
        throw NotImplementedError()
    }

    private fun preventSilentAccess() {

    }

    private fun hasCredentialFeature(): Boolean {
        return true
    }
}
