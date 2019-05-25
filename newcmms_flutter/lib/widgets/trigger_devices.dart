import 'dart:collection';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:newcmms_flutter/models/trigger_device.model.dart';
import 'package:newcmms_flutter/models/trigger_device.repository.dart';
import 'package:newcmms_flutter/utils/common.dart';
import '../di.dart';
import '../localizations.dart';
import '../services/http_client.service.dart';

class TriggerDevices extends StatefulWidget {
  final double _viewPortHeight;

  TriggerDevices(this._viewPortHeight);

  @override
  State<StatefulWidget> createState() {
    return ModuleContainer.getDefault().get<TriggerDevicesState>(additionalParameters: {
      TriggerDevicesState.viewportHeightParamName: _viewPortHeight,
    });
  }
}

class TriggerDevicesState extends State<TriggerDevices> {
  static const viewportHeightParamName = 'viewportHeight';
  final TriggerDeviceRepository _triggerDeviceStore;
  final double _viewportHeight;
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _snackbar;
  Future<UnmodifiableListView<TriggerDevice>> _loadFuture;

  TriggerDevicesState(this._triggerDeviceStore, double viewportHeight)
    : assert(viewportHeight != null), _viewportHeight = viewportHeight;

  @override
  void initState() {
    super.initState();
    if (_triggerDeviceStore.list == null) {
      _loadFuture = _triggerDeviceStore.refresh();
      _loadFuture.catchError(_handleError)
          .whenComplete(() {
            _loadFuture = null;
            _setStateSafely();
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _getBody();
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

  Widget _getBody() {
    if (_loadFuture != null) {
      return Align(
        alignment: Alignment(0, -0.3),
        child: CircularProgressIndicator(
          value: null,
        ),
      );
    } else {
      return RefreshIndicator(
        onRefresh: () => _triggerDeviceStore.refresh().then((user) {
          _setStateSafely();
        }).catchError(_handleError),
        child: _getListBody(),
      );
    }
  }

  Widget _getListBody() {
    final localization = AppLocalizations.of(context);
    if (_triggerDeviceStore.list == null || _triggerDeviceStore.list.length == 0) {
      return ScrollConfiguration(
        behavior: NoOverScrollGlow(),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            height: _viewportHeight,
            child: Align(
              alignment: Alignment(0, -0.3),
              child: Text(AppLocalizations
                .of(context)
                .emptyList)
            ),
          ),
        ),
      );
    } else {
      return ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: _triggerDeviceStore.list.length,
        itemBuilder: (context, index) {
          final device = _triggerDeviceStore.list[index];
          return Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.title),
                  title: Text(device.name),
                  subtitle: Text(device.type),
                ),
                ListTile(
                  leading: Icon(Icons.confirmation_number),
                  title: Text(device.physicalAddress),
                  subtitle: Text(localization.triggerDevicePhysicalAddress),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Chip(
                    label: Text(device.status.toLocalizedString(context),
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
      );
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

  void _hideSnackbar() {
    if (_snackbar != null) {
      _snackbar.close();
      _snackbar = null;
    }
  }
}
