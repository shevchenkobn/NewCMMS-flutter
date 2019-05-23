
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../di.dart';
import '../services/auth.service.dart';
import '../services/http_client.service.dart';
import 'login.page.dart';

class HomePage extends StatefulWidget {
  static const routerName = '/';

  @override
  State<StatefulWidget> createState() => ModuleContainer.getDefault().get<HomePageState>();
}

class HomePageState extends State<HomePage> {
  final AuthService _authService;
  final HttpClient _httpClient;

  HomePageState(this._authService, this._httpClient);

  @override
  void initState() {
    if (!_authService.isAuthorized) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(LoginPage.routerName);
      });
      return;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold();
  }
}