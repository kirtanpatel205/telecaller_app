import 'package:telecaller_app/generated/json/base/json_convert_content.dart';
import 'package:telecaller_app/core/models/user_setting_response_entity.dart';

UserSettingResponseEntity $UserSettingResponseEntityFromJson(
    Map<String, dynamic> json) {
  final UserSettingResponseEntity userSettingResponseEntity = UserSettingResponseEntity();
  final bool? status = jsonConvert.convert<bool>(json['status']);
  if (status != null) {
    userSettingResponseEntity.status = status;
  }
  final UserSettingResponseUserSetting? userSetting = jsonConvert.convert<
      UserSettingResponseUserSetting>(json['userSetting']);
  if (userSetting != null) {
    userSettingResponseEntity.userSetting = userSetting;
  }
  return userSettingResponseEntity;
}

Map<String, dynamic> $UserSettingResponseEntityToJson(
    UserSettingResponseEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['status'] = entity.status;
  data['userSetting'] = entity.userSetting?.toJson();
  return data;
}

extension UserSettingResponseEntityExtension on UserSettingResponseEntity {
  UserSettingResponseEntity copyWith({
    bool? status,
    UserSettingResponseUserSetting? userSetting,
  }) {
    return UserSettingResponseEntity()
      ..status = status ?? this.status
      ..userSetting = userSetting ?? this.userSetting;
  }
}

UserSettingResponseUserSetting $UserSettingResponseUserSettingFromJson(
    Map<String, dynamic> json) {
  final UserSettingResponseUserSetting userSettingResponseUserSetting = UserSettingResponseUserSetting();
  final UserSettingResponseUserSettingTelecallerSettings? telecallerSettings = jsonConvert
      .convert<UserSettingResponseUserSettingTelecallerSettings>(
      json['telecallerSettings']);
  if (telecallerSettings != null) {
    userSettingResponseUserSetting.telecallerSettings = telecallerSettings;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    userSettingResponseUserSetting.id = id;
  }
  final String? userId = jsonConvert.convert<String>(json['userId']);
  if (userId != null) {
    userSettingResponseUserSetting.userId = userId;
  }
  final String? panelId = jsonConvert.convert<String>(json['panelId']);
  if (panelId != null) {
    userSettingResponseUserSetting.panelId = panelId;
  }
  final List<dynamic>? support = (json['support'] as List<dynamic>?)?.map(
          (e) => e).toList();
  if (support != null) {
    userSettingResponseUserSetting.support = support;
  }
  final List<dynamic>? devices = (json['devices'] as List<dynamic>?)?.map(
          (e) => e).toList();
  if (devices != null) {
    userSettingResponseUserSetting.devices = devices;
  }
  final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
  if (createdAt != null) {
    userSettingResponseUserSetting.createdAt = createdAt;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    userSettingResponseUserSetting.updatedAt = updatedAt;
  }
  final int? v = jsonConvert.convert<int>(json['__v']);
  if (v != null) {
    userSettingResponseUserSetting.v = v;
  }
  return userSettingResponseUserSetting;
}

Map<String, dynamic> $UserSettingResponseUserSettingToJson(
    UserSettingResponseUserSetting entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['telecallerSettings'] = entity.telecallerSettings?.toJson();
  data['_id'] = entity.id;
  data['userId'] = entity.userId;
  data['panelId'] = entity.panelId;
  data['support'] = entity.support;
  data['devices'] = entity.devices;
  data['createdAt'] = entity.createdAt;
  data['updatedAt'] = entity.updatedAt;
  data['__v'] = entity.v;
  return data;
}

extension UserSettingResponseUserSettingExtension on UserSettingResponseUserSetting {
  UserSettingResponseUserSetting copyWith({
    UserSettingResponseUserSettingTelecallerSettings? telecallerSettings,
    String? id,
    String? userId,
    String? panelId,
    List<dynamic>? support,
    List<dynamic>? devices,
    String? createdAt,
    String? updatedAt,
    int? v,
  }) {
    return UserSettingResponseUserSetting()
      ..telecallerSettings = telecallerSettings ?? this.telecallerSettings
      ..id = id ?? this.id
      ..userId = userId ?? this.userId
      ..panelId = panelId ?? this.panelId
      ..support = support ?? this.support
      ..devices = devices ?? this.devices
      ..createdAt = createdAt ?? this.createdAt
      ..updatedAt = updatedAt ?? this.updatedAt
      ..v = v ?? this.v;
  }
}

UserSettingResponseUserSettingTelecallerSettings $UserSettingResponseUserSettingTelecallerSettingsFromJson(
    Map<String, dynamic> json) {
  final UserSettingResponseUserSettingTelecallerSettings userSettingResponseUserSettingTelecallerSettings = UserSettingResponseUserSettingTelecallerSettings();
  final UserSettingResponseUserSettingTelecallerSettingsAllowCalls? allowCalls = jsonConvert
      .convert<UserSettingResponseUserSettingTelecallerSettingsAllowCalls>(
      json['allowCalls']);
  if (allowCalls != null) {
    userSettingResponseUserSettingTelecallerSettings.allowCalls = allowCalls;
  }
  return userSettingResponseUserSettingTelecallerSettings;
}

Map<String, dynamic> $UserSettingResponseUserSettingTelecallerSettingsToJson(
    UserSettingResponseUserSettingTelecallerSettings entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['allowCalls'] = entity.allowCalls?.toJson();
  return data;
}

extension UserSettingResponseUserSettingTelecallerSettingsExtension on UserSettingResponseUserSettingTelecallerSettings {
  UserSettingResponseUserSettingTelecallerSettings copyWith({
    UserSettingResponseUserSettingTelecallerSettingsAllowCalls? allowCalls,
  }) {
    return UserSettingResponseUserSettingTelecallerSettings()
      ..allowCalls = allowCalls ?? this.allowCalls;
  }
}

UserSettingResponseUserSettingTelecallerSettingsAllowCalls $UserSettingResponseUserSettingTelecallerSettingsAllowCallsFromJson(
    Map<String, dynamic> json) {
  final UserSettingResponseUserSettingTelecallerSettingsAllowCalls userSettingResponseUserSettingTelecallerSettingsAllowCalls = UserSettingResponseUserSettingTelecallerSettingsAllowCalls();
  final String? from = jsonConvert.convert<String>(json['from']);
  if (from != null) {
    userSettingResponseUserSettingTelecallerSettingsAllowCalls.from = from;
  }
  return userSettingResponseUserSettingTelecallerSettingsAllowCalls;
}

Map<String,
    dynamic> $UserSettingResponseUserSettingTelecallerSettingsAllowCallsToJson(
    UserSettingResponseUserSettingTelecallerSettingsAllowCalls entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['from'] = entity.from;
  return data;
}

extension UserSettingResponseUserSettingTelecallerSettingsAllowCallsExtension on UserSettingResponseUserSettingTelecallerSettingsAllowCalls {
  UserSettingResponseUserSettingTelecallerSettingsAllowCalls copyWith({
    String? from,
  }) {
    return UserSettingResponseUserSettingTelecallerSettingsAllowCalls()
      ..from = from ?? this.from;
  }
}