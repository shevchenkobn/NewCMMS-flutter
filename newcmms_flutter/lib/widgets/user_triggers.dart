import 'dart:collection';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:newcmms_flutter/models/user_trigger.model.dart';
import 'package:newcmms_flutter/models/user_trigger.repository.dart';
import 'package:newcmms_flutter/models/trigger_device.model.dart';
import 'package:newcmms_flutter/models/trigger_device.repository.dart';
import 'package:newcmms_flutter/utils/common.dart';
import '../di.dart';
import '../localizations.dart';
import 'trigger_device.dart';

class UserTriggers extends StatefulWidget {
  final double _viewPortHeight;

  UserTriggers(this._viewPortHeight);

  @override
  State<StatefulWidget> createState() {
    return ModuleContainer.getDefault().get<UserTriggersState>(additionalParameters: {
      UserTriggersState.viewportHeightParamName: _viewPortHeight,
    });
  }
}

class UserTriggersState extends State<UserTriggers> {
  static const viewportHeightParamName = 'viewportHeight';
  final UserTriggerRepository _userTriggerRepository;
  final TriggerDeviceRepository _triggerDeviceRepository;
  final double _viewportHeight;
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _snackbar;
  Future<dynamic> _loadFuture;

  UserTriggersState(this._userTriggerRepository, this._triggerDeviceRepository, double viewportHeight)
    : assert(viewportHeight != null), _viewportHeight = viewportHeight;

  @override
  void initState() {
    super.initState();
    if (_triggerDeviceRepository.list == null) {
      _loadFuture = _refresh();
      _loadFuture.catchError(_handleError)
          .whenComplete(() {
        _loadFuture = null;
        _setStateSafely();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadFuture != null) {
      return Align(
        alignment: Alignment(0, -0.3),
        child: CircularProgressIndicator(
          value: null,
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => _refresh().then((devices) {
        _hideSnackbar();
        _setStateSafely();
      }).catchError(_handleError),
      child: _getListBody(),
    );;
  }

  @override
  void dispose() {
    _hideSnackbar();
    super.dispose();
  }

  Future<dynamic> _refresh() => Future.wait([
    _userTriggerRepository.refresh(),
    _triggerDeviceRepository.refresh(),
  ]);

  void _setStateSafely({VoidCallback cb}) {
    if (mounted) {
      setState(cb ?? () {});
    }
  }

  Widget _getListBody() {
    final localization = AppLocalizations.of(context);
    if (
      _userTriggerRepository.list == null || _userTriggerRepository.list.length == 0
      || _triggerDeviceRepository.map == null || _triggerDeviceRepository.map.length == 0
    ) {
      return ScrollConfiguration(
        behavior: NoOverScrollGlow(),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            height: _viewportHeight,
            child: Align(
                alignment: Alignment(0, -0.3),
                child: Text(localization.nothingFound)
            ),
          ),
        ),
      );
    } else {
      return ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: _userTriggerRepository.list.length,
        itemBuilder: (context, index) {
          final userTrigger = _userTriggerRepository.list[index];
          final triggerDevice = _triggerDeviceRepository.map[userTrigger.triggerDeviceId];
          return Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _getTriggerDeviceTile(triggerDevice),
                ListTile(
                  leading: Icon(Icons.date_range),
                  title: Text(
                    DateFormat.yMMMMEEEEd().add_Hms().format(userTrigger.triggerTime),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Chip(
                    label: Text(userTrigger.triggerType.toLocalizedString(context),
                        style: TextStyle(
                          color: Colors.white,
                        )
                    ),
                    backgroundColor: _getChipColor(userTrigger.triggerType),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Widget _getTriggerDeviceTile(TriggerDevice triggerDevice) {
    final localization = AppLocalizations.of(context);
    if (triggerDevice == null) {
      return ListTile(
        leading: Icon(Icons.device_unknown),
        title: Text(localization.userTriggerTriggerDeviceNameUnknown),
        subtitle: Text(localization.userTriggerTriggerDeviceName),
      );
    } else {
      return ListTile(
        leading: Icon(Icons.developer_board),
        title: Text(triggerDevice.name),
        subtitle: Text(localization.userTriggerTriggerDeviceName),
        trailing: IconButton(
          icon: Icon(Icons.open_in_new),
          onPressed: () {
            TriggerDevicePage.navigateTo(context, triggerDevice);
          },
        ),
      );
    }
  }

  Color _getChipColor(UserTriggerType triggerType) {
    if (triggerType == UserTriggerType.enter) {
      return Colors.pinkAccent;
    } else if (triggerType == UserTriggerType.leave) {
      return Colors.blue;
    } else {
      return Colors.blueGrey;
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