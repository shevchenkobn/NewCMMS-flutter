
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:newcmms_flutter/widgets/home.page.dart';

import 'services/auth.service.dart';
import 'services/http_client.service.dart';
import 'widgets/login.page.dart';

class ModuleContainer {
  static Injector getDefault() => Injector.getInjector();

  Future<Injector> initializeDefault() => initialize(getDefault());

  Future<Injector> initialize(Injector injector) async {
    // Async init
    final authService = await AuthService.getInstance();
    injector.map<AuthService>((i) => authService, isSingleton: true);

    injector.map<HttpClient>((i) => HttpClient(i.get<AuthService>()), isSingleton: true);

    injector.map<LoginPageState>((i) => LoginPageState(i.get<AuthService>(), i.get<HttpClient>()));
    injector.map<HomePageState>((i) {
      return HomePageState(i.get<AuthService>(), i.get<HttpClient>());
    });

    return injector;
  }
}
