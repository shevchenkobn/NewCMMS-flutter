import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

import '../localizations.dart';

part 'trigger_device.model.g.dart';

class TriggerDeviceStatus {
  static const connected = const TriggerDeviceStatus._(1);
  static const disconnected = const TriggerDeviceStatus._(2);

  final int value;
  factory TriggerDeviceStatus(int value) {
    if (value < connected.value || value > disconnected.value) {
      throw new ArgumentError.value(value, 'value', 'Value must be a valid enum value');
    }
    return TriggerDeviceStatus._(value);
  }
  const TriggerDeviceStatus._(int allowedValue) : value = allowedValue;

  @override
  String toString() {
    switch (value) {
      case 1:
        return 'connected';
      case 2:
        return 'disconnected';
      default:
        return '_';
    }
  }

  String toLocalizedString(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (this == connected) {
      return localizations.triggerDeviceStatusConnected;
    } else {
      return localizations.triggerDeviceStatusDisconnected;
    }
  }

  @override
  int get hashCode => value;
  operator ==(dynamic other) => other is TriggerDeviceStatus ? value == other.value : value == other;
}

TriggerDeviceStatus triggerDeviceStatusFromJson(int json) => TriggerDeviceStatus(json);
int triggerDeviceStatusToJson(TriggerDeviceStatus status) => status?.value;

@JsonSerializable()
class TriggerDevice {
  int triggerDeviceId;
  String physicalAddress;
  @JsonKey(fromJson: triggerDeviceStatusFromJson, toJson: triggerDeviceStatusToJson)
  TriggerDeviceStatus status;
  String name;
  String type;

  TriggerDevice({this.triggerDeviceId, this.physicalAddress, this.status, this.name, this.type});

  factory TriggerDevice.fromJson(Map<String, dynamic> json) => _$TriggerDeviceFromJson(json);
  Map<String, dynamic> toJson() => _$TriggerDeviceToJson(this);
}