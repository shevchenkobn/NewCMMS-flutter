import 'dart:convert';

import '../models/user.model.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:jose/jose.dart';

class AuthService {
  static const authRefreshPath = 'auth/refresh/';
  static const authPath = 'auth/';
  static const authRefreshTokenKey = 'apiRefreshToken';
  static const authAccessTokenKey = 'apiAccessToken';
  static const authUserKey = 'apiAccessToken';

  String _refreshToken;
  String _accessToken;
  DateTime _accessTokenExpiration;
  SharedPreferences _prefs;
  Future<String> _tokenRefresher;
  User _user;

  bool get isTokenExpired => _accessTokenExpiration?.isBefore(DateTime.now());
  String get accessToken => _accessToken;
  bool get hasTokens => _refreshToken != null && _accessToken != null;
  User get user => _user;
  Future<bool> saveUser(User user) {
    _user = user;
    return _prefs.setString(authUserKey, jsonEncode(user.toJson()));
  }

  AuthService(SharedPreferences prefs) {
    _prefs = prefs;
    if (_prefs.containsKey(authRefreshTokenKey)) {
      _refreshToken = _prefs.getString(authRefreshTokenKey);
    }
    if (_prefs.containsKey(authAccessTokenKey)) {
      _accessToken = _prefs.getString(authAccessTokenKey);
      _setTokenExpiration();
    }
    if (_prefs.containsKey(authUserKey)) {
      _user = User.fromJson(jsonDecode(_prefs.getString(authUserKey)));
    }
  }

  static bool isPathWithoutAuth(String path) {
    return path == authPath || path == authRefreshPath;
  }

  Future<void> setTokens({String accessToken, String refreshToken}) async {
    if (accessToken == null) {
      throw new ArgumentError.notNull('accessToken');
    }
    if (refreshToken == null) {
      throw new ArgumentError.notNull('refreshToken');
    }
    _accessToken = accessToken;
    refreshToken = refreshToken;
    _setTokenExpiration();
    await Future.wait([
        _prefs.setString(authAccessTokenKey, _accessToken),
        _prefs.setString(authRefreshTokenKey, _refreshToken),
    ]);
  }

  Future<String> getEnsuredToken(Dio dio) {
    if (_accessToken != null && !isTokenExpired) {
      return Future.value(_accessToken);
    }
    if (_tokenRefresher != null) {
      return _tokenRefresher;
    }
    _tokenRefresher = _doUpdateAccessToken(dio);
    return _tokenRefresher;
  }

  Future<String> _doUpdateAccessToken(Dio dio) async {
    if (_refreshToken == null) {
      throw new StateError('Refresh token is not defined');
    }
    Response response = await dio.post(authRefreshPath,
        data: {
          'refreshToken': _refreshToken,
        },
        queryParameters: {
          'include-refresh-token': true,
        }
    );
    await setTokens(
      accessToken: response.data['accessToken'],
      refreshToken: response.data['refreshToken'],
    );
    return _accessToken;
  }

  MapEntry<String, String> getTokenHeader() {
    if (_accessToken == null) {
      throw new ArgumentError.notNull();
    }
    return MapEntry('Authorization', 'Bearer ' + _accessToken);
  }

  void _setTokenExpiration() {
    final jws = JsonWebSignature.fromCompactSerialization(_accessToken);
    _accessTokenExpiration = jws.unverifiedPayload.jsonContent["exp"];
  }
}
