// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_trigger.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserTrigger _$UserTriggerFromJson(Map<String, dynamic> json) {
  return UserTrigger(
      userTriggerId: json['userTriggerId'] as int,
      userId: json['userId'] as int,
      triggerDeviceId: json['triggerDeviceId'] as int,
      triggerTime: json['triggerTime'] == null
          ? null
          : DateTime.parse(json['triggerTime'] as String),
      triggerType: userTriggerTypeFromJson(json['triggerType'] as int));
}

Map<String, dynamic> _$UserTriggerToJson(UserTrigger instance) =>
    <String, dynamic>{
      'userTriggerId': instance.userTriggerId,
      'userId': instance.userId,
      'triggerDeviceId': instance.triggerDeviceId,
      'triggerTime': instance.triggerTime?.toIso8601String(),
      'triggerType': userTriggerTypeToJson(instance.triggerType)
    };
