import 'package:telecaller_app/generated/json/base/json_field.dart';
import 'package:telecaller_app/generated/json/user_setting_response_entity.g.dart';
import 'dart:convert';
export 'package:telecaller_app/generated/json/user_setting_response_entity.g.dart';

@JsonSerializable()
class UserSettingResponseEntity {
	bool? status = false;
	UserSettingResponseUserSetting? userSetting;

	UserSettingResponseEntity();

	factory UserSettingResponseEntity.fromJson(Map<String, dynamic> json) => $UserSettingResponseEntityFromJson(json);

	Map<String, dynamic> toJson() => $UserSettingResponseEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class UserSettingResponseUserSetting {
	UserSettingResponseUserSettingTelecallerSettings? telecallerSettings;
	@JSONField(name: '_id')
	String? id = '';
	String? userId = '';
	String? panelId = '';
	List<dynamic>? support = [];
	List<dynamic>? devices = [];
	String? createdAt = '';
	String? updatedAt = '';
	@JSONField(name: '__v')
	int? v = 0;

	UserSettingResponseUserSetting();

	factory UserSettingResponseUserSetting.fromJson(Map<String, dynamic> json) => $UserSettingResponseUserSettingFromJson(json);

	Map<String, dynamic> toJson() => $UserSettingResponseUserSettingToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class UserSettingResponseUserSettingTelecallerSettings {
	UserSettingResponseUserSettingTelecallerSettingsAllowCalls? allowCalls;

	UserSettingResponseUserSettingTelecallerSettings();

	factory UserSettingResponseUserSettingTelecallerSettings.fromJson(Map<String, dynamic> json) => $UserSettingResponseUserSettingTelecallerSettingsFromJson(json);

	Map<String, dynamic> toJson() => $UserSettingResponseUserSettingTelecallerSettingsToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class UserSettingResponseUserSettingTelecallerSettingsAllowCalls {
	String? from = '';

	UserSettingResponseUserSettingTelecallerSettingsAllowCalls();

	factory UserSettingResponseUserSettingTelecallerSettingsAllowCalls.fromJson(Map<String, dynamic> json) => $UserSettingResponseUserSettingTelecallerSettingsAllowCallsFromJson(json);

	Map<String, dynamic> toJson() => $UserSettingResponseUserSettingTelecallerSettingsAllowCallsToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}