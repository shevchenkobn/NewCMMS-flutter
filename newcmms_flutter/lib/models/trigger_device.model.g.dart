// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trigger_device.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TriggerDevice _$TriggerDeviceFromJson(Map<String, dynamic> json) {
  return TriggerDevice(
      triggerDeviceId: json['triggerDeviceId'] as int,
      physicalAddress: json['physicalAddress'] as String,
      status: triggerDeviceStatusFromJson(json['status'] as int),
      name: json['name'] as String,
      type: json['type'] as String);
}

Map<String, dynamic> _$TriggerDeviceToJson(TriggerDevice instance) =>
    <String, dynamic>{
      'triggerDeviceId': instance.triggerDeviceId,
      'physicalAddress': instance.physicalAddress,
      'status': triggerDeviceStatusToJson(instance.status),
      'name': instance.name,
      'type': instance.type
    };
