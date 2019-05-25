import 'package:json_annotation/json_annotation.dart';

part 'user_trigger.model.g.dart';

class UserTriggerType {
  static const unspecified = const UserTriggerType._(0);
  static const enter = const UserTriggerType._(1);
  static const leave = const UserTriggerType._(2);

  final int value;
  factory UserTriggerType(int value) {
    if (value < unspecified.value || value > leave.value) {
      throw new ArgumentError.value(value, 'value', 'Value must be a valid enum');
    }
    return UserTriggerType._(value);
  }
  const UserTriggerType._(int allowedValue) : value = allowedValue;

  @override
  String toString() {
    switch (value) {
      case 0:
        return 'unspecified';
      case 1:
        return 'enter';
      case 2:
        return 'leave';
      default:
        return '_';
    }
  }

  @override
  int get hashCode => value;
  operator ==(dynamic other) => other is UserTriggerType ? value == other.value : value == other;
}

int userTriggerTypeToJson(UserTriggerType triggerType) => triggerType?.value;
UserTriggerType userTriggerTypeFromJson(int json) => UserTriggerType(json);

@JsonSerializable()
class UserTrigger {
  int userTriggerId;
  int userId;
  int triggerDeviceId;
  DateTime triggerTime;
  @JsonKey(fromJson: userTriggerTypeFromJson, toJson: userTriggerTypeToJson)
  UserTriggerType triggerType;

  UserTrigger({ this.userTriggerId, this.userId, this.triggerDeviceId, this.triggerTime, this.triggerType });

  factory UserTrigger.fromJson(Map<String, dynamic> json) => _$UserTriggerFromJson(json);
  Map<String, dynamic> toJson() => _$UserTriggerToJson(this);

  @override
  int get hashCode => userTriggerId;

  @override
  bool operator ==(other) => other is UserTrigger ? other.userTriggerId == userTriggerId : false;
}
