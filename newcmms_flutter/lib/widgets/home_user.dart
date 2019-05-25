import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:newcmms_flutter/utils/common.dart';

import '../di.dart';
import '../localizations.dart';
import '../services/auth.service.dart';
import '../services/http_client.service.dart';

class HomeUser extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return ModuleContainer.getDefault().get<HomeUserState>();
  }
}

class HomeUserState extends State<HomeUser> {
  final AuthService _authService;
  final HttpClient _httpClient;
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _snackbar;

  HomeUserState(this._authService, this._httpClient);

  @override
  void initState() {
    super.initState();
    if (_authService.user == null) {
      _httpClient.refreshCurrentUser().then((user) {
        _setStateSafely();
      }).catchError(_handleError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return RefreshIndicator(
      onRefresh: () => _httpClient.refreshCurrentUser().then((user) {
          _setStateSafely();
        }).catchError(_handleError),
      child: ScrollConfiguration(
        behavior: NoOverScrollGlow(),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.email),
                  title: Text(
                      _authService.user?.email ?? localizations.loading),
                  subtitle: Text(localizations.userEmail),
                ),
                ListTile(
                  leading: Icon(Icons.perm_identity),
                  title: Text(
                      _authService.user?.fullName ?? localizations.loading),
                  subtitle: Text(localizations.userFullName),
                ),
                SizedBox(height: 20),
                Wrap(
                  children: _authService.user?.role.getLocalizedSingleNames(
                      context).map(
                        (s) =>
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Chip(
                            padding: EdgeInsets.all(10),
                            label: Text(s,
                                style: TextStyle(
                                  color: Colors.white,
                                )
                            ),
                            backgroundColor: Colors.pinkAccent,
                          ),
                        ),
                  ).toList(growable: false) ?? [],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_snackbar != null) {
      _snackbar.close();
      _snackbar = null;
    }
    super.dispose();
  }

  void _handleError(error, stackTrace) {
    String content;
    if (error is DioError) {
      if (error.type == DioErrorType.DEFAULT && error.error is SocketException) {
        content = AppLocalizations
            .of(context).internetError;
      } else {
        content = AppLocalizations
            .of(context).userLoadError;
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
    _snackbar.closed.then((_) {
      _snackbar = null;
    });
  }

  void _setStateSafely({VoidCallback cb}) {
    if (mounted) {
      setState(cb ?? () {});
    }
  }
}