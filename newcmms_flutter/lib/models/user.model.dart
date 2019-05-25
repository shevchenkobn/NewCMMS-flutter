import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../localizations.dart';

part 'user.model.g.dart';

class UserRoles {
  static const employee = const UserRoles._(1);
  static const admin = const UserRoles._(2);
  static const employeeAndAdmin = const UserRoles._(1 | 2);

  final int value;
  factory UserRoles(int value) {
    if (value < employee.value || value > employeeAndAdmin.value) {
      throw new ArgumentError.value(value, 'value', 'Value must be a valid enum value');
    }
    return UserRoles._(value);
  }
  const UserRoles._(int allowedValue) : value = allowedValue;

  static bool isSingle(int value) => value >= employee.value && value <= admin.value;

  @override
  String toString() {
    switch (value) {
      case 1:
        return 'employee';
      case 2:
        return 'admin';
      case 3:
        return 'employee+admin';
      default:
        return '_';
    }
  }

  List<String> getLocalizedSingleNames(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final roles = <String>[];
    if (this & employee != 0) {
      roles.add(localizations.userRoleEmployee);
    }
    if (this & admin != 0) {
      roles.add(localizations.userRoleAdmin);
    }
    return roles;
  }

  @override
  int get hashCode => value;

  operator &(UserRoles other) => UserRoles._(value & other.value);
  operator |(UserRoles other) => UserRoles._(value | other.value);
  operator ==(dynamic other) => other is UserRoles ? value == other.value : value == other;

}

UserRoles userRolesFromJson(int json) => UserRoles(json);
int userRolesToJson(UserRoles object) => object?.value;

final userRoleConverter = UserRoleJsonConverter();

class UserRoleJsonConverter implements JsonConverter<UserRoles, int> {
  @override
  UserRoles fromJson(int json) => UserRoles._(json);

  @override
  int toJson(UserRoles object) => object?.value;
}

@JsonSerializable()
class User {
  int userId;
  String email;
  @JsonKey(fromJson: userRolesFromJson, toJson: userRolesToJson)
  UserRoles role;
  String fullName;

  User({this.userId, this.email, this.role, this.fullName});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
