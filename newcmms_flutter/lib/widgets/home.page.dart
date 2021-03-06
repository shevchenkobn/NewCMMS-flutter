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
import 'user_triggers.dart';

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
  PageContentType _contentType;
  AppBar _appBar;

  HomePageState(this._authService);

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
      case PageContentType.triggerHistory:
        return localizations.userTriggersPageTitle;
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
          redirectTo: (pageContentType) {
            // Handle logout
            if (pageContentType != PageContentType.login) {
              Navigator.pop(context);
            }
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
      case PageContentType.triggerHistory:
        return UserTriggers(_getViewportHeight());
      default:
        throw new StateError('Content for $_contentType is not found!');
    }
  }

  double _getViewportHeight() {
    return MediaQuery.of(context).size.height - (_appBar == null ? 56 : _appBar.preferredSize.height);
  }
}