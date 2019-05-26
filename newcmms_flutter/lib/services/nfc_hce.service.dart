import 'package:flutter/services.dart';

import 'auth.service.dart';

class NfcHceService {
  static const _platform = const MethodChannel('com.newcmms/nfc_hce');
  static const _ndefMessageParam = 'ndefValue';
  static const _isNfcEnabledMethod = 'isNfcEnabled';
  static const _isServiceRunningMethod = 'isServiceRunning';
  static const _openNfcSettingsMethod = 'openNfcSettings';
  static const _setNewStringValueMethod = 'setNewStringValue';
  static const _startServiceMethod = 'startService';
  static const _stopServiceMethod = 'stopService';

  final AuthService _authService;

  NfcHceService(this._authService) {
    _loopForceSetToken();
    _authService.accessTokenChange.listen((newToken) {
      forceSetToken().catchError((error, stackTrace) {
        print('Update HCE token error');
        print(error);
        print(stackTrace);
      });
    });
  }

  Future<bool> isNfcServiceRunning() async {
    final isRunning = await _platform.invokeMethod<bool>(_isServiceRunningMethod);
    return isRunning;
  }

  Future<bool> isNfcEnabled() async {
    final isEnabled = await _platform.invokeMethod<bool>(_isNfcEnabledMethod);
    return isEnabled;
  }

  Future<void> openNfcSettings() {
    return _platform.invokeMethod(_openNfcSettingsMethod);
  }

  Future<void> forceSetToken() {
    return _platform.invokeMethod(_setNewStringValueMethod, <String, dynamic>{
      _ndefMessageParam: _authService.accessToken,
    });
  }

  Future<void> startService() {
    return _platform.invokeMethod(_startServiceMethod);
  }

  Future<void> stopService() {
    return _platform.invokeMethod(_stopServiceMethod);
  }

  Future<void> _loopForceSetToken() async {
    while (true) {
      try {
        await forceSetToken();
        return;
      } catch (error, stackTrace) {
        print('Update HCE token error');
        print(error);
        print(stackTrace);
      }
    }
  }
}