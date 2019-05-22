import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:jose/jose.dart';

class AuthService {
  static const authRefreshPath = 'auth/refresh/';
  static const authPath = 'auth/';
  static const authRefreshTokenKey = 'apiRefreshToken';
  static const authAccessTokenKey = 'apiAccessToken';

  String _refreshToken;
  String _accessToken;
  DateTime _accessTokenExpiration;
  SharedPreferences _prefs;
  Future<String> _tokenRefresher;

  get isTokenExpired => _accessTokenExpiration?.isBefore(DateTime.now());
  get accessToken => _accessToken;
  get isAuthorized => _refreshToken != null && _accessToken != null;

  AuthService._create();

  static getInstance() async {
    final inst = AuthService._create();
    await inst._init();
    return inst;
  }

  static isPathWithoutAuth(String path) {
    return path == authPath || path == authRefreshPath;
  }

  _init() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs.containsKey(authRefreshTokenKey)) {
      _refreshToken = _prefs.getString(authRefreshTokenKey);
    }
    if (_prefs.containsKey(authAccessTokenKey)) {
      _accessToken = _prefs.getString(authAccessTokenKey);
      _setTokenExpiration();
    }
  }

  setTokens({String accessToken, String refreshToken}) async {
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

  _setTokenExpiration() {
    final jws = JsonWebSignature.fromCompactSerialization(_accessToken);
    _accessTokenExpiration = jws.unverifiedPayload.jsonContent["exp"];
  }
}
