
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:newcmms_flutter/widgets/home.page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/auth.service.dart';
import 'services/http_client.service.dart';
import 'widgets/general_settings.page.dart';
import 'widgets/home_drawer_content.dart';
import 'widgets/login.dart';
import 'widgets/login_drawer_content.dart';

class ModuleContainer {
  static Injector getDefault() => Injector.getInjector();

  Future<Injector> initializeDefault() => initialize(getDefault());

  Future<Injector> initialize(Injector injector) async {
    // Async init
    var prefs = await SharedPreferences.getInstance();
    injector.map<SharedPreferences>((i) => prefs, isSingleton: true);

    injector.map<AuthService>((i) => AuthService(i.get<SharedPreferences>()), isSingleton: true);
    injector.map<HttpClient>((i) => HttpClient(i.get<SharedPreferences>(), i.get<AuthService>()), isSingleton: true);

    injector.mapWithParams<LoginState>((i, params) => LoginState(i.get<AuthService>(), i.get<HttpClient>(), params['onReturn']));
    injector.map<HomePageState>((i) => HomePageState(i.get<AuthService>(), i.get<HttpClient>()));
    injector.map<LoginDrawerContentState>((i) => LoginDrawerContentState());
    injector.map<HomeDrawerContentState>((i) => HomeDrawerContentState(i.get<HttpClient>(), i.get<AuthService>()));
    injector.map<GeneralSettingsPageState>((i) => GeneralSettingsPageState(i.get<HttpClient>()));

    return injector;
  }
}
