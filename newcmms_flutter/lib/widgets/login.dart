import 'dart:io';

import 'package:stack_trace/stack_trace.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:newcmms_flutter/utils/common.dart';
import 'package:validators/validators.dart';

import '../di.dart';
import '../localizations.dart';
import '../services/http_client.service.dart';
import '../services/auth.service.dart';
import 'home.page.dart';

class Login extends StatefulWidget {
  final ReturnCallback _onFinish;

  Login({@required ReturnCallback onFinish}) : assert(onFinish != null), _onFinish = onFinish;

  @override
  State<StatefulWidget> createState() => ModuleContainer.getDefault().get<LoginState>(additionalParameters: {
    LoginState.onFinishParamName: _onFinish
  });
}

class LoginState extends State<Login> {
  static const onFinishParamName = 'onFinish';
  final AuthService _authService;
  final HttpClient _httpClient;
  final ReturnCallback _onFinish;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isProcessing = false;
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _snackbar;

  LoginState(this._authService, this._httpClient, ReturnCallback onFinish)
    : assert(onFinish != null), _onFinish = onFinish;

  @override
  void initState() {
    if (_authService.hasTokens) {
      _onFinish();
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
      list.add(Align(
        alignment: AlignmentDirectional.topCenter,
        child: LinearProgressIndicator(
          value: null,
        )
      ));
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
                  obscureText: true,
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
                      ).whenComplete(() {
                        setState(() {
                          _isProcessing = false;
                        });
                        _hideSnackbar();
                      }).then((_) {
                        try {
                          _onFinish();
                          dispose();
                        } catch (error) {
                          print('Error while finishing');
                          print(error);
                        }
                      }).catchError((error, stackTrace) {
                        String content;
                        if (error is DioError) {
                          if (error.type == DioErrorType.DEFAULT && error.error is SocketException) {
                            content = AppLocalizations
                                .of(context).internetError;
                          } else {
                            content = AppLocalizations
                                .of(context).loginPageLoginOrPasswordError;
                          }
                        } else {
                          content = AppLocalizations
                              .of(context).unknownError;
                          print(error);
                          print(stackTrace);
                        }
                        _snackbar = Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text(content),
                          duration: Duration(days: 10),
                          action: SnackBarAction(
                            label: AppLocalizations
                              .of(context).ok,
                            onPressed: () {},
                            textColor: Colors.redAccent,
                          ),
                        ));
                      });
                    },
                    child: Text(AppLocalizations
                        .of(context)
                        .loginPageSubmitLabel),
                    color: Colors.blue,
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
  @override
  void dispose() {
    _hideSnackbar();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _hideSnackbar() {
    if (_snackbar != null) {
      _snackbar.close();
      _snackbar = null;
    }
  }
}