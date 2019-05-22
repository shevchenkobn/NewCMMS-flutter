import 'package:dio/dio.dart';
import 'package:validators/validators.dart';

import 'auth.service.dart';

class HttpClient {
  static const defaultBaseUrl = 'http://192.168.0.104:3000';
  static const apiBase = '/api/v1';

  final AuthService _authService;
  final Dio _dio = Dio();
  String _baseUrl;

  get baseUrl => _baseUrl;

  HttpClient(this._authService) {
    _dio.options.baseUrl = defaultBaseUrl + apiBase;
  }

  setBaseUrl(String baseUrl, { bool addApiBase = true }) {
    if (!isURL(baseUrl) || baseUrl.endsWith('/')) {
      throw new ArgumentError.value(baseUrl, 'baseUrl');
    }
    _baseUrl = addApiBase ? baseUrl + apiBase : baseUrl;
  }
}
