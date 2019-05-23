// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
      userId: json['userId'] as int,
      email: json['email'] as String,
      role: userRolesFromJson(json['role'] as int),
      fullName: json['fullName'] as String);
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'userId': instance.userId,
      'email': instance.email,
      'role': userRolesToJson(instance.role),
      'fullName': instance.fullName
    };
