
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:newcmms_flutter/widgets/home.page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/trigger_device.repository.dart';
import 'services/auth.service.dart';
import 'services/http_client.service.dart';
import 'widgets/general_settings.page.dart';
import 'widgets/home_drawer_content.dart';
import 'widgets/home_user.dart';
import 'widgets/login.dart';
import 'widgets/login_drawer_content.dart';
import 'widgets/trigger_device.dart';
import 'widgets/trigger_devices.dart';

class ModuleContainer {
  static Injector getDefault() => Injector.getInjector();

  Future<Injector> initializeDefault() => initialize(getDefault());

  Future<Injector> initialize(Injector injector) async {
    // Async init
    var prefs = await SharedPreferences.getInstance();
    injector.map<SharedPreferences>((i) => prefs, isSingleton: true);

    injector.map<AuthService>((i) => AuthService(i.get<SharedPreferences>()), isSingleton: true);
    injector.map<HttpClient>((i) => HttpClient(i.get<SharedPreferences>(), i.get<AuthService>()), isSingleton: true);
    injector.map<TriggerDeviceRepository>((i) => TriggerDeviceRepository(i.get<HttpClient>()), isSingleton: true);

    injector.mapWithParams<LoginState>((i, params) => LoginState(i.get<AuthService>(), i.get<HttpClient>(), params[LoginState.onFinishParamName]));
    injector.map<HomePageState>((i) => HomePageState(i.get<AuthService>(), i.get<HttpClient>()));
    injector.map<LoginDrawerContentState>((i) => LoginDrawerContentState());
    injector.mapWithParams<HomeDrawerContentState>((i, params) => HomeDrawerContentState(i.get<HttpClient>(), i.get<AuthService>(), params[HomeDrawerContentState.redirectToParamName]));
    injector.map<GeneralSettingsPageState>((i) => GeneralSettingsPageState(i.get<HttpClient>(), i.get<AuthService>()));
    injector.map<HomeUserState>((i) => HomeUserState(i.get<AuthService>(), i.get<HttpClient>()));
    injector.mapWithParams<TriggerDevicesState>((i, params) => TriggerDevicesState(i.get<TriggerDeviceRepository>(), params[TriggerDevicesState.viewportHeightParamName] as double));
    injector.map<TriggerDevicePageState>((i) => TriggerDevicePageState(i.get<TriggerDeviceRepository>()));

    return injector;
  }
}
