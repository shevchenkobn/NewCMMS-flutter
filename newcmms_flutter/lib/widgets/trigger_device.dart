import 'dart:collection';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:newcmms_flutter/models/trigger_device.model.dart';
import 'package:newcmms_flutter/models/trigger_device.repository.dart';
import 'package:newcmms_flutter/utils/common.dart';
import '../di.dart';
import '../localizations.dart';

class TriggerDevicePage extends StatefulWidget {
  static const routeName = 'trigger-device/';
  static void navigateTo(BuildContext context, TriggerDevice device) => Navigator.of(context).pushNamed(routeName, arguments: [device]);
  static void _navigateFrom(BuildContext context) => Navigator.of(context).pop();

  TriggerDevicePage();

  @override
  State<StatefulWidget> createState() {
    return ModuleContainer.getDefault().get<TriggerDevicePageState>();
  }
}

class TriggerDevicePageState extends State<TriggerDevicePage> {
  final TriggerDeviceRepository _triggerDeviceStore;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  TriggerDevice _triggerDevice;
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _snackbar;

  TriggerDevicePageState(this._triggerDeviceStore);

  @override
  Widget build(BuildContext context) {
    _setInitialTriggerDevice();
    final localization = AppLocalizations.of(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(localization.triggerDevicePageTitle),
      ),
      body: RefreshIndicator(
        onRefresh: () => _triggerDeviceStore.refreshOne(_triggerDevice.triggerDeviceId).then((device) {
          _setStateSafely(cb: () {
            _triggerDevice = device;
          });
        }).catchError(_handleError),
        child: ScrollConfiguration(
          behavior: NoOverScrollGlow(),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: _getBody(),
          )
        )
      ),
    );
  }

  void _setInitialTriggerDevice() {
    if (_triggerDevice == null) {
      _triggerDevice = (ModalRoute
          .of(context)
          .settings
          .arguments as List<dynamic>)[0] as TriggerDevice;
    }
  }

  Widget _getBody() {
    final localization = AppLocalizations.of(context);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.title),
            title: Text(this._triggerDevice.name),
            subtitle: Text(localization.triggerDeviceName),
          ),
          ListTile(
            leading: Icon(Icons.text_fields),
            title: Text(this._triggerDevice.type),
            subtitle: Text(localization.triggerDeviceType),
          ),
          ListTile(
            leading: Icon(Icons.confirmation_number),
            title: Text(this._triggerDevice.physicalAddress),
            subtitle: Text(localization.triggerDevicePhysicalAddress),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Chip(
              padding: EdgeInsets.all(10),
              label: Text(_triggerDevice.status.toLocalizedString(context),
                  style: TextStyle(
                    color: Colors.white,
                  )
              ),
              backgroundColor: Colors.pinkAccent,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _hideSnackbar();
    super.dispose();
  }

  void _setStateSafely({VoidCallback cb}) {
    if (mounted) {
      setState(cb ?? () {});
    }
  }

  void _handleError(error, stackTrace) {
    String content;
    if (error is DioError && error.type == DioErrorType.DEFAULT && error.error is SocketException) {
      content = AppLocalizations
          .of(context).internetError;
    } else {
      content = AppLocalizations
          .of(context).unknownError;
      print(error);
      print(stackTrace);
    }
    _hideSnackbar();
    _snackbar = _scaffoldKey.currentState.showSnackBar(SnackBar(
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

  void _hideSnackbar() {
    if (_snackbar != null) {
      _snackbar.close();
      _snackbar = null;
    }
  }
}
