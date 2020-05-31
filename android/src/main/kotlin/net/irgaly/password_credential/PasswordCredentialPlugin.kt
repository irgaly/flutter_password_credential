package net.irgaly.password_credential

import android.app.Activity
import android.content.Intent
import androidx.annotation.NonNull;
import com.google.android.gms.auth.api.credentials.Credential
import com.google.android.gms.auth.api.credentials.Credentials
import com.google.android.gms.auth.api.credentials.CredentialsClient
import com.google.android.gms.auth.api.credentials.CredentialsOptions

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import kotlinx.coroutines.*
import kotlinx.serialization.UnstableDefault
import kotlinx.serialization.json.Json
import net.irgaly.password_credential.entity.Mediation
import net.irgaly.password_credential.entity.PasswordCredential
import kotlin.coroutines.Continuation
import kotlin.coroutines.CoroutineContext
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

@Suppress("unused")
class PasswordCredentialPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener, CoroutineScope {
    private lateinit var channel: MethodChannel
    private lateinit var job: Job
    override val coroutineContext: CoroutineContext get() = job + Dispatchers.Default

    private var requestCodeSave = 1129
    private var requestCodeRead = 1130

    private lateinit var credentialsClient: CredentialsClient
    var pendingSaveContinuation: Continuation<Unit>? = null
    var pendingReadContinuation: Continuation<PasswordCredential?>? = null
    val pendingLock = Object()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        job = Job()
        channel = MethodChannel(flutterPluginBinding.flutterEngine.dartExecutor, "password_credential").apply {
            setMethodCallHandler(this@PasswordCredentialPlugin)
        }
        credentialsClient = Credentials.getClient(
                flutterPluginBinding.applicationContext,
                CredentialsOptions.Builder()
                        // not to use Autofill confirmation dialog
                        .forceEnableSaveDialog()
                        .build()
        )
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        job.cancel()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        when (requestCode) {
            requestCodeSave -> {
                synchronized(pendingLock) {
                    pendingSaveContinuation?.resume(when (resultCode) {
                        Activity.RESULT_OK -> Unit
                        else -> Unit // this is user cancel, or other error. but ignore this error.
                    })
                    pendingSaveContinuation = null
                }
                return true
            }
            requestCodeRead -> {
                synchronized(pendingLock) {
                    pendingReadContinuation?.resume(
                            when (resultCode) {
                                Activity.RESULT_OK ->
                                    data?.getParcelableExtra<Credential>(Credential.EXTRA_KEY)?.let { credential ->
                                        val password = credential.password
                                        if (password != null) {
                                            PasswordCredential(
                                                    credential.id,
                                                    password,
                                                    credential.name,
                                                    credential.profilePictureUri.toString()
                                            )
                                        } else {
                                            null // Credential is not password credential.
                                        }
                                    }
                                else -> null // this is user cancel, or other error. this results to null.
                            }
                    )
                    pendingReadContinuation = null
                }
                return true
            }
        }
        return false
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
                        result.success(store(credential))
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

    private suspend fun store(credential: PasswordCredential): Boolean {
        throw NotImplementedError()
    }

    private suspend fun delete(id: String) = suspendCancellableCoroutine<Unit>{ continuation ->
        credentialsClient.delete(Credential.Builder(id).build()).addOnCompleteListener {
            continuation.resume(Unit)
        }
    }

    private suspend fun preventSilentAccess() = suspendCancellableCoroutine<Unit>{ continuation ->
        credentialsClient.disableAutoSignIn().addOnCompleteListener {
            continuation.resume(Unit)
        }
    }

    private fun hasCredentialFeature(): Boolean {
        return true
    }
}
