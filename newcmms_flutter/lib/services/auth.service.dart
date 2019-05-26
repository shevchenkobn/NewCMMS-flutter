import 'dart:async';
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
  static const authUserKey = 'authUser';

  String _refreshToken;
  String _accessToken;
  StreamController<String> _accessTokenChange;
  DateTime _accessTokenExpiration;
  SharedPreferences _prefs;
  Future<String> _tokenRefresher;
  User _user;

  bool get isTokenExpired =>
      _accessTokenExpiration == null ||
          _accessTokenExpiration.isBefore(DateTime.now());
  String get accessToken => _accessToken;
  Stream<String> get accessTokenChange => _accessTokenChange.stream;
  bool get hasTokens => _refreshToken != null && _accessToken != null;
  User get user => _user;

  AuthService(SharedPreferences prefs) {
    _prefs = prefs;
    if (_prefs.containsKey(authRefreshTokenKey)) {
      _refreshToken = _prefs.getString(authRefreshTokenKey);
    }
    _accessTokenChange = new StreamController.broadcast();
    if (_prefs.containsKey(authAccessTokenKey)) {
      _accessToken = _prefs.getString(authAccessTokenKey);
      _setTokenExpiration();
      _accessTokenChange.add(_accessToken);
    }
    if (_prefs.containsKey(authUserKey)) {
      _user = User.fromJson(jsonDecode(_prefs.getString(authUserKey)));
    }
  }

  static bool isPathWithoutAuth(String path) {
    return path == authPath || path == authRefreshPath;
  }

  Future<bool> saveUser(User user) {
    _user = user;
    return _prefs.setString(authUserKey, jsonEncode(user.toJson()));
  }

  Future<void> setTokens({String accessToken, String refreshToken}) async {
    if (accessToken == null) {
      throw new ArgumentError.notNull('accessToken');
    }
    if (refreshToken == null) {
      throw new ArgumentError.notNull('refreshToken');
    }
    _accessToken = accessToken;
    _setTokenExpiration();
    _accessTokenChange.add(accessToken);
    _refreshToken = refreshToken;
    await Future.wait([
        _prefs.setString(authAccessTokenKey, _accessToken),
        _prefs.setString(authRefreshTokenKey, _refreshToken),
    ]);
  }

  Future<String> getEnsuredToken(Dio dio) {
    if (!isTokenExpired) {
      return Future.value(_accessToken);
    }
    if (_tokenRefresher != null) {
      return _tokenRefresher;
    }
    _tokenRefresher = _doUpdateAccessToken(dio);
    _tokenRefresher.whenComplete(() => _tokenRefresher = null);
    return _tokenRefresher;
  }

  Future<String> _doUpdateAccessToken(Dio dio) async {
    if (_refreshToken == null) {
      throw new StateError('Refresh token is not defined');
    }
    Response response = await dio.post(authRefreshPath,
        data: {
          'accessToken': _accessToken,
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

  Future<void> logout() async {
    await Future.wait([
      _prefs.remove(authUserKey),
      _prefs.remove(authRefreshTokenKey),
      _prefs.remove(authAccessTokenKey),
    ]);
    _accessToken = null;
    _accessTokenChange.add(_accessToken);
    _refreshToken = null;
    _user = null;
  }

  void _setTokenExpiration() {
    final jws = JsonWebSignature.fromCompactSerialization(_accessToken);
    _accessTokenExpiration = DateTime.fromMicrosecondsSinceEpoch(jws.unverifiedPayload.jsonContent["exp"]);
  }
}
