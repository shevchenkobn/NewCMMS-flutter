package com.newcmms.newcmms_flutter

import android.content.ComponentName
import android.content.Intent
import android.nfc.NfcAdapter
import android.os.Bundle
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity: FlutterActivity() {
  private val CHANNEL = "com.newcmms/nfc_hce"
  private val NFEF_STRING_PARAM_NAME = "ndefValue"
  private lateinit var _stringValue: String
  private var _isNfcServiceRunning = false

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)

    setIsNfcRunningByRestart()
    MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
      try {
        when (call.method) {
          "isNfcEnabled" -> {
            result.success(isNfcEnabled())
          }
          "isServiceRunning" -> {
            result.success(_isNfcServiceRunning)
          }
          "openNfcSettings" -> {
            startNfcSettingsActivity()
            result.success(null)
          }
          "setNewStringValue" -> {
            if (!call.hasArgument(NFEF_STRING_PARAM_NAME) || call.argument<String>(NFEF_STRING_PARAM_NAME) == null) {
              result.notImplemented()
            } else {
              setNewStringValue(call.argument<String>(NFEF_STRING_PARAM_NAME) as String)
            }
          }
          else -> result.notImplemented()
        }
      } catch (err: Exception) {
        result.error(err.message, err.stackTrace.toString(), err.toString())
      }

    }
  }

  private fun setIsNfcRunningByRestart() {
    val wasRunning = stopNfcService()
    if (!wasRunning) {
      return
    }
    startNfcService()
  }

  private fun isNfcEnabled(): Boolean {
    val nfcAdapter = NfcAdapter.getDefaultAdapter(this)
    return nfcAdapter == null || nfcAdapter.isEnabled
  }

  private fun setNewStringValue(value: String) {
    stopNfcService()
    startNfcService(value)
  }

  protected fun startNfcSettingsActivity() {
    if (android.os.Build.VERSION.SDK_INT >= 16) {
      startActivity(Intent(android.provider.Settings.ACTION_NFC_SETTINGS))
    } else {
      startActivity(Intent(android.provider.Settings.ACTION_WIRELESS_SETTINGS))
    }
  }

  private fun startNfcService(value: String = _stringValue): ComponentName? {
    val intent = Intent(this, NfcTextNdefHceService::class.java)
    _stringValue = value
    intent.putExtra(NfcTextNdefHceService.NDEF_KEY, value)
    val componentName = startService(intent)
    _isNfcServiceRunning = componentName != null
    return componentName
  }

  private fun stopNfcService(): Boolean {
    val intent = Intent(this, NfcTextNdefHceService::class.java)
    val wasRunning = stopService(intent)
    _isNfcServiceRunning = false
    return wasRunning
  }
}
