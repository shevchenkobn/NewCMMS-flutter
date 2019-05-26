package com.newcmms.newcmms_flutter

import android.content.ComponentName
import android.content.Intent
import android.content.ServiceConnection
import android.os.Bundle
import android.os.IBinder
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
  private var _nfcService: NfcTextNdefHceService? = null
  private var _nfcServiceConnection = object : ServiceConnection {
    override fun onServiceDisconnected(name: ComponentName?) {
      _nfcService = null
    }

    override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
      _nfcService = (service as NfcTextNdefHceService.NfcServiceBinder).getService()
    }
  }


  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)
    val intent = Intent(this, NfcTextNdefHceService::class.java)
    startService(intent)
  }
}
