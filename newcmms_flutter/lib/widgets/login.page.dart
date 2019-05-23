import 'package:flutter/material.dart';
import 'package:validators/validators.dart';

import '../di.dart';
import '../localizations.dart';
import '../services/auth.service.dart';
import '../services/http_client.service.dart';
import 'home.page.dart';

class LoginPage extends StatefulWidget {
  static const String routerName = '/login';

  @override
  State<StatefulWidget> createState() => ModuleContainer.getDefault().get<LoginPageState>();
}

class LoginPageState extends State<LoginPage> {
  final AuthService _authService;
  final HttpClient _httpClient;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  LoginPageState(this._authService, this._httpClient);

  @override
  void initState() {
    if (_authService.isAuthorized) {
      final navigator = Navigator.of(context);
      var hasFound = false;
      try {
        navigator.popUntil((route) {
          hasFound = route.settings.name == HomePage.routerName;
          return hasFound;
        });
      } on StateError {}
      if (!hasFound) {
        navigator.pushNamed(HomePage.routerName);
      }
      return;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations
            .of(context)
            .loginPageTitle),
      ),
      body: Align(
        alignment: Alignment(0, -0.3),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: AppLocalizations
                        .of(context)
                        .loginPageLoginLabel,
                  ),
                  validator: (value) {
                    if (value.isEmpty || !isEmail(value)) {
                      return AppLocalizations
                          .of(context)
                          .loginPageEmailError;
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: AppLocalizations
                        .of(context)
                        .loginPagePasswordLabel,
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return AppLocalizations
                          .of(context)
                          .loginPagePasswordError;
                    }
                    return null;
                  },
                ),
                Padding(
                    padding: EdgeInsets.all(12.0),
                    child: RaisedButton(
                      onPressed: () {
                        if (!_formKey.currentState.validate()) {
                          return;
                        }
                        // TODO: Authenticate
                      },
                      child: Text(AppLocalizations
                          .of(context)
                          .loginPageSubmitLabel),
                      color: Colors.lightBlue,
                      textColor: Colors.white,
                    )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}