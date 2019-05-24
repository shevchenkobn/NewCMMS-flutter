import 'package:flutter/material.dart';
import 'package:newcmms_flutter/utils/common.dart';
import 'package:validators/validators.dart';

import '../di.dart';
import '../localizations.dart';
import '../services/auth.service.dart';
import '../services/http_client.service.dart';
import 'home.page.dart';

class Login extends StatefulWidget {
  final ReturnCallback _onFinish;

  Login({ReturnCallback onFinish}) : _onFinish = onFinish;

  @override
  State<StatefulWidget> createState() => ModuleContainer.getDefault().get<LoginState>(additionalParameters: {
    'onFinish': _onFinish
  });
}

class LoginState extends State<Login> {
  final AuthService _authService;
  final HttpClient _httpClient;
  final ReturnCallback _onFinish;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isProcessing = false;

  LoginState(this._authService, this._httpClient, this._onFinish);

  @override
  void initState() {
    if (_authService.hasTokens) {
      this._onFinish();
      return;
    }
//    if (_authService.hasTokens) {
//      final navigator = Navigator.of(context);
//      var hasFound = false;
//      try {
//        navigator.popUntil((route) {
//          hasFound = route.settings.name == HomePage.routerName;
//          return hasFound;
//        });
//      } on StateError {}
//      if (!hasFound) {
//        navigator.pushNamed(HomePage.routerName);
//      }
//      return;
//    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final list = <Widget>[
      Positioned(
        top: 0,
        bottom: 0,
        left: 0,
        right: 0,
        child: _getBody(),
      )
    ];
    if (_isProcessing) {
      list.add(Align(alignment: AlignmentDirectional.topCenter,child:LinearProgressIndicator(
          value: null,
      )));
    }
    return Stack(
      alignment: AlignmentDirectional.center,
      children: list,
    );
  }

  Widget _getBody() {
    return Align(
      alignment: Alignment(0, -0.3),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 22.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
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
                  controller: _passwordController,
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
                    onPressed: _isProcessing ? null : () {
                      if (!_formKey.currentState.validate()) {
                        return;
                      }
                      setState(() {
                        _isProcessing = true;
                      });
                      _httpClient.authenticate(
                        email: _emailController.text,
                        password: _passwordController.text,
                      ).then((_) {
                        _onFinish();
                      }).catchError((error) {
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text(AppLocalizations
                              .of(context).loginPageLoginOrPasswordError),
                          duration: Duration(days: 10),
                          action: SnackBarAction(label: AppLocalizations
                              .of(context).ok, onPressed: () {}),
                        ));
                      }).whenComplete(() {
//                        setState(() {
//                          _isProcessing = false;
//                        });
                      });
                    },
                    child: Text(AppLocalizations
                        .of(context)
                        .loginPageSubmitLabel),
                    color: Colors.lightBlue,
                    textColor: Colors.white,
                  )
                ),
              ],
            )
          ),
        ),
      ),
    );
  }
}