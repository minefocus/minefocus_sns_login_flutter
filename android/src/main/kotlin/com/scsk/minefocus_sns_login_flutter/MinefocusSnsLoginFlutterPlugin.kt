package com.scsk.minefocus_sns_login_flutter

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.util.*

/** MinefocusSnsLoginFlutterPlugin */
public class MinefocusSnsLoginFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {

  override fun onDetachedFromActivity() {
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    binding.addOnNewIntentListener { intent ->
      intent?.let {
        mLoginUtils?.yahooOnResume(it)
      }
      true
    }
  }

  override fun onDetachedFromActivityForConfigChanges() {
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "minefocus_sns_login_flutter")
    channel.setMethodCallHandler(MinefocusSnsLoginFlutterPlugin());
    mLoginUtils = LoginUtils { type, token ->
      token?.let {
        val param = HashMap<String, Any>()
        param["success"] = true
        param["yahooAccessToken"] = token
        mResult?.success(param)
      }
    }
    mLoginUtils?.yahooInit(flutterPluginBinding.applicationContext)
  }

  companion object {
    var mLoginUtils: LoginUtils? = null
    private var mResult: Result? = null
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "minefocus_sns_login_flutter")
      channel.setMethodCallHandler(MinefocusSnsLoginFlutterPlugin())
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    mResult = result
    when {
        call.method == "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
        call.method == "yahooLogIn" -> mLoginUtils?.yahooSignIn()
        else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    mLoginUtils = null
  }

}
