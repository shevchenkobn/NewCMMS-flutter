import 'package:dio/dio.dart';
import 'package:newcmms_flutter/models/trigger_device.model.dart';
import 'package:validators/validators.dart';
import 'package:dio_flutter_transformer/dio_flutter_transformer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth.service.dart';
import '../models/user.model.dart';

class HttpClient {
  static const defaultBaseUrl = 'http://192.168.0.104:3000/';
  static const apiBase = 'api/v1/';
  static const apiBaseKey = 'apiBase';

  final AuthService _authService;
  final SharedPreferences _prefs;
  final Dio _dio;
  String _baseUrl;

  Dio get dio => _dio;
  String get baseUrl => _baseUrl;

  HttpClient(this._prefs, this._authService) : _dio = Dio() {
    setBaseUrl(this._prefs.get(apiBaseKey) ?? defaultBaseUrl);
    _dio.transformer = new FlutterTransformer();
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (RequestOptions options) async {
        if (AuthService.isPathWithoutAuth(options.path)) {
          return options;
        }
        await _authService.getEnsuredToken(_dio);
        final tokenHeader = _authService.getTokenHeader();
        options.headers[tokenHeader.key] = tokenHeader.value;
        return options;
      }
    ));
  }

  Future<bool> setBaseUrl(String baseUrl, { bool addApiBase = true }) async {
    if (!isURL(baseUrl)) {
      throw new ArgumentError.value(baseUrl, 'baseUrl');
    }
    _baseUrl = baseUrl.endsWith('/') ? baseUrl : baseUrl + '/';
    _dio.options.baseUrl = addApiBase ? _baseUrl + apiBase : _baseUrl;
    return _prefs.setString(apiBaseKey, _baseUrl);
  }

  Future<User> refreshCurrentUser() async {
    if (!_authService.hasTokens) {
      throw new StateError('The user is not authorized');
    }
    Response<Map<String, dynamic>> response = await _dio.get('auth/identity');
    final user = User.fromJson(response.data);
    await _authService.saveUser(user);
    return user;
  }

  Future<void> authenticate({String email, String password}) async {
    Response response = await _dio.post('auth/', data: {
      'email': email,
      'password': password,
    });
    await _authService.setTokens(accessToken: response.data['accessToken'],
        refreshToken: response.data['refreshToken']);
  }

  Future<List<TriggerDevice>> getTriggerDevices({bool growableList = true}) async {
    return _dio.get<Map<String, dynamic>>('trigger-devices/')
      .then((response) =>
        (response.data['triggerDevices'] as List<Map<String, dynamic>>)
            .map((json) => TriggerDevice.fromJson(json)).toList(growable: growableList)
      );
  }
}
