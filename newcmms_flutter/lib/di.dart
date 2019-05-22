
import 'package:flutter_simple_dependency_injection/injector.dart';

import 'services/auth.service.dart';
import 'services/http_client.service.dart';

class ModuleContainer {
  static Injector getDefault() => Injector.getInjector();

  Injector initializeDefault() => initialize(getDefault());

  Injector initialize(Injector injector) {
    injector.map((i) => AuthService.getInstance(),
        isSingleton: true);
    injector.map((i) => HttpClient(i.get<AuthService>()), isSingleton: true);

    return injector;
  }
}
