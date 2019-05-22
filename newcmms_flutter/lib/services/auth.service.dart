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

  get isTokenExpired => _accessTokenExpiration?.isBefore(DateTime.now());
  get accessToken => _accessToken;

  static getInstance() async {
    final inst = AuthService._create();
    await inst._init();
    return inst;
  }

  AuthService._create();

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
    _accessToken = accessToken;
    refreshToken = refreshToken;
    await Future.wait([
        _prefs.setString(authAccessTokenKey, _accessToken),
        _prefs.setString(authRefreshTokenKey, _refreshToken),
    ]);
    _setTokenExpiration();
  }

  getEnsuredToken(Dio dio) async {
    if (_accessToken != null && !isTokenExpired) {
      return _accessToken;
    }
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

  getTokenHeader() {
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
