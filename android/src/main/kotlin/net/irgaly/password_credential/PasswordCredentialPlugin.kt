package net.irgaly.password_credential

import android.app.Activity
import android.content.ComponentName
import android.content.Intent
import android.util.Log
import com.google.android.gms.auth.api.credentials.*
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.common.api.CommonStatusCodes
import com.google.android.gms.common.api.ResolvableApiException

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
import kotlinx.serialization.json.JsonConfiguration
import net.irgaly.password_credential.entity.Mediation
import net.irgaly.password_credential.entity.PasswordCredential
import net.irgaly.password_credential.entity.mediationFrom
import kotlin.coroutines.*

@Suppress("unused")
class PasswordCredentialPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener, CoroutineScope {
    private lateinit var channel: MethodChannel
    private lateinit var job: Job
    private var activity: Activity? = null
    override val coroutineContext: CoroutineContext get() = job + Dispatchers.Default

    private var requestCodeSave = 1129
    private var requestCodeRead = 1130

    private lateinit var credentialsClient: CredentialsClient
    private var pendingSaveContinuation: Continuation<Boolean>? = null
    private var pendingReadContinuation: Continuation<PasswordCredential?>? = null
    private val pendingLock = Object()
    private val json = Json(JsonConfiguration.Stable.copy(isLenient = false))

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
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        job.cancel()
    }

    @OptIn(UnstableDefault::class)
    override fun onMethodCall(call: MethodCall, result: Result) {
        launch(Dispatchers.Main) {
            try {
                when (call.method) {
                    "hasCredentialFeature" -> result.success(hasCredentialFeature())
                    "get" -> {
                        val mediation = call.argument<String>("mediation")?.let {
                            mediationFrom(it)
                        } ?: throw IllegalArgumentException("mediation is null")
                        val ret = get(mediation)?.let {
                            json.stringify(PasswordCredential.serializer(), it)
                        }
                        result.success(ret)
                    }
                    "store" -> {
                        val credential = call.argument<String>("credential")?.let {
                            json.parse(PasswordCredential.serializer(), it)
                        } ?: throw IllegalArgumentException("credential is null")
                        val mediation = call.argument<String>("mediation")?.let {
                            mediationFrom(it)
                        } ?: throw IllegalArgumentException("mediation is null")
                        result.success(store(credential, mediation))
                    }
                    "delete" -> {
                        val id = call.argument<String>("id")
                                ?: throw IllegalArgumentException("id is null")
                        delete(id)
                        result.success(null)
                    }
                    "preventSilentAccess" -> {
                        preventSilentAccess()
                        result.success(null)
                    }
                    "openPlatformCredentialSettings" -> {
                        openPlatformCredentialSettings()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Throwable) {
                result.error(e.javaClass.name, e.message, Log.getStackTraceString(e))
            }
        }
    }

    private fun hasCredentialFeature(): Boolean {
        return true
    }

    private suspend fun get(mediation: Mediation): PasswordCredential? {
        if (mediation == Mediation.Required) {
            // disable Silent Access
            suspendCoroutine<Unit> { continuation ->
                credentialsClient.disableAutoSignIn().addOnCompleteListener {
                    continuation.resume(Unit)
                }
            }
        }
        return suspendCoroutine { continuation ->
            credentialsClient.request(CredentialRequest.Builder()
                    .setPasswordLoginSupported(true) // get ID/Password Credential
                    .build()).addOnCompleteListener { task ->
                val e = task.exception
                val result = if (e == null) task.result else null
                val credential = result?.credential
                when {
                    (credential != null) -> {
                        val password = credential.password
                        val ret = if (password != null) {
                            PasswordCredential(
                                    credential.id,
                                    password,
                                    credential.name,
                                    credential.profilePictureUri.toString()
                            )
                        } else {
                            null // Credential is not password credential.
                        }
                        continuation.resume(ret)
                    }
                    e is ResolvableApiException -> {
                        if (mediation != Mediation.Silent) {
                            synchronized(pendingLock) {
                                pendingReadContinuation?.resume(null)
                                pendingReadContinuation = continuation
                            }
                            e.startResolutionForResult(activity, requestCodeRead)
                        } else {
                            continuation.resume(null) // mediation is Silent, so failed to get credential
                        }
                    }
                    e is ApiException ->
                        continuation.resume(when (e.statusCode) {
                            CommonStatusCodes.SIGN_IN_REQUIRED -> null // This is Hint (= ID) only Credential
                            CommonStatusCodes.API_NOT_CONNECTED -> null // GooglePlayServices is missing, or Access Error
                            CommonStatusCodes.CANCELED -> null // Smartlock for Passwords is disabled by user system setting
                            else -> null // unknown error
                        })
                    else -> continuation.resume(null) // this cannot be happen, treat as failed for safe.
                }
            }
        }
    }

    private suspend fun store(credential: PasswordCredential, mediation: Mediation): Boolean {
        if (credential.id.isEmpty()) {
            throw IllegalArgumentException("id cannot be empty")
        }
        if (credential.password.isEmpty()) {
            throw IllegalArgumentException("password cannot be empty")
        }
        if (mediation == Mediation.Required) {
            // disable Silent Access
            suspendCoroutine<Unit> { continuation ->
                credentialsClient.delete(Credential.Builder(credential.id).build()).addOnCompleteListener {
                    continuation.resume(Unit)
                }
            }
        }
        return suspendCoroutine { continuation ->
            credentialsClient.save(Credential.Builder(credential.id)
                    .setPassword(credential.password)
                    .build()).addOnCompleteListener { task ->
                val e = task.exception
                when {
                    task.isSuccessful -> continuation.resume(true) // Save Complete with no user interaction
                    e is ResolvableApiException -> {
                        // User Action is required at first credential save
                        if (mediation != Mediation.Silent) {
                            synchronized(pendingLock) {
                                pendingSaveContinuation?.resume(false)
                                pendingSaveContinuation = continuation
                            }
                            pendingSaveContinuation = continuation
                            e.startResolutionForResult(activity, requestCodeSave)
                        } else {
                            continuation.resume(false) // User interaction is not allowed
                        }
                    }
                    e is ApiException ->
                        continuation.resume(when (e.statusCode) {
                            CommonStatusCodes.API_NOT_CONNECTED -> false // GooglePlayServices is missing, or Access Error
                            CommonStatusCodes.CANCELED -> false // Smartlock for Passwords is disabled by user system setting
                            else -> false // unknown error
                        })
                    else -> continuation.resume(false) // this cannot be happen, treat as failed for safe.
                }
            }
        }
    }

    private suspend fun delete(id: String) = suspendCoroutine<Unit> { continuation ->
        if (id.isEmpty()) {
            throw IllegalArgumentException("id cannot be empty")
        }
        credentialsClient.delete(Credential.Builder(id).build()).addOnCompleteListener {
            continuation.resume(Unit)
        }
    }

    private suspend fun preventSilentAccess() = suspendCoroutine<Unit> { continuation ->
        credentialsClient.disableAutoSignIn().addOnCompleteListener {
            continuation.resume(Unit)
        }
    }

    private fun openPlatformCredentialSettings() {
        // Open Google Play Services Account Settings
        activity?.startActivity(Intent().apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            component = ComponentName("com.google.android.gms", "com.google.android.gms.app.settings.GoogleSettingsIALink")
        })
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        when (requestCode) {
            requestCodeSave -> {
                synchronized(pendingLock) {
                    pendingSaveContinuation?.resume(when (resultCode) {
                        Activity.RESULT_OK -> true
                        else -> false // this is user cancel, or other error.
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
}
