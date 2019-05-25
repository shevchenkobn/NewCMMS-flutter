import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../di.dart';
import '../localizations.dart';
import '../services/auth.service.dart';
import '../services/http_client.service.dart';
import 'home_drawer_content.dart';
import 'home_user.dart';
import 'login.dart';
import 'login_drawer_content.dart';
import 'trigger_devices.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/';

  @override
  State<StatefulWidget> createState() => ModuleContainer.getDefault().get<HomePageState>();
}

enum PageContentType {
  login, triggerHistory, user, triggers
}

class HomePageState extends State<HomePage> {
  final AuthService _authService;
  final HttpClient _httpClient;
  PageContentType _contentType;
  AppBar _appBar;

  HomePageState(this._authService, this._httpClient);

  @override
  void initState() {
    super.initState();
    _contentType = _authService.hasTokens ? PageContentType.user : PageContentType.login;
//    if (!_authService.isAuthorized) {
//      SchedulerBinding.instance.addPostFrameCallback((_) {
//        Navigator.of(context).pushReplacementNamed(LoginPage.routerName);
//      });
//      return;
//    }
  }

  @override
  Widget build(BuildContext context) {
    _appBar = AppBar(
      title: Text(_getTitle()),
    );
    return Scaffold(
      appBar: _appBar,
      drawer: Drawer(
        child: _getDrawerContent(),
      ),
      body: _getContent(),
    );
  }

  String _getTitle() {
    var localizations = AppLocalizations.of(context);
    switch (_contentType) {
      case PageContentType.user:
        return localizations.userPageTitle;
      case PageContentType.login:
        return localizations.loginPageTitle;
      case PageContentType.triggers:
        return localizations.triggerDevicesPageTitle;
      default:
        return localizations.title;
    }
  }

  Widget _getDrawerContent() {
    switch (_contentType) {
      case PageContentType.login:
        return LoginDrawerContent();
      default:
        return HomeDrawerContent(
          onItemTap: (pageContentType) {
            Navigator.of(context).pop();
            if (_contentType != pageContentType) {
              setState(() {
                _contentType = pageContentType;
              });
            }
          },
        );
    }
  }

  Widget _getContent() {
    switch (_contentType) {
      case PageContentType.login:
        return Login(
          onFinish: () {
            setState(() {
              _contentType = PageContentType.user;
            });
          },
        );
      case PageContentType.user:
        return HomeUser();
      case PageContentType.triggers:
        return TriggerDevices(_getViewportHeight());
      default:
        return Center(child: Text('not found'));
    }
  }

  double _getViewportHeight() {
    if (_appBar == null) {
      return 228;
    }
    return MediaQuery.of(context).size.height - _appBar.preferredSize.height;
  }
}