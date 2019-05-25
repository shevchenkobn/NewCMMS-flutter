import 'package:flutter/material.dart';
import 'package:newcmms_flutter/models/trigger_device.repository.dart';
import '../di.dart';
import '../localizations.dart';
import '../services/http_client.service.dart';

class TriggerDevices extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ModuleContainer.getDefault().get<TriggerDevicesState>();
  }
}

class TriggerDevicesState extends State<TriggerDevices> {
  final TriggerDeviceRepository _triggerDeviceStore;

  TriggerDevicesState(this._triggerDeviceStore);

  @override
  Widget build(BuildContext context) {
    return null;
  }

  void _setStateSafely({VoidCallback cb}) {
    if (mounted) {
      setState(cb ?? () {});
    }
  }
}
