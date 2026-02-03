import 'package:telecaller_app/generated/json/base/json_field.dart';
import 'package:telecaller_app/generated/json/login_response_entity.g.dart';
import 'dart:convert';
export 'package:telecaller_app/generated/json/login_response_entity.g.dart';

@JsonSerializable()
class LoginResponseEntity {
	bool? status = false;
	String? token = '';
	LoginResponseProfile? profile;

	LoginResponseEntity();

	factory LoginResponseEntity.fromJson(Map<String, dynamic> json) => $LoginResponseEntityFromJson(json);

	Map<String, dynamic> toJson() => $LoginResponseEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class LoginResponseProfile {
	LoginResponseProfileAddress? address;
	@JSONField(name: '_id')
	String? id = '';
	String? name = '';
	String? authType = '';
	String? phone = '';
	String? profile = '';
	int? wallet = 0;
	String? panelId = '';
	String? status = '';
	String? role = '';
	List<String>? assignedTo = [];
	List<dynamic>? badge = [];
	dynamic pin;
	List<dynamic>? whiteList = [];
	LoginResponseProfileWhatsapp? whatsapp;
	bool? telecallerRedeem = false;
	List<dynamic>? sharedWith = [];
	bool? rebrand = false;
	List<dynamic>? rebrandProducts = [];
	LoginResponseProfileSubscription? subscription;
	String? createdAt = '';
	String? updatedAt = '';
	@JSONField(name: '__v')
	int? v = 0;
	dynamic teamId;
	String? email = '';
	String? lastLoginAt = '';
	String? fixOTP = '';
	String? fcmToken = '';
	int? otpVerify = 0;
	int? otpSent = 0;

	LoginResponseProfile();

	factory LoginResponseProfile.fromJson(Map<String, dynamic> json) => $LoginResponseProfileFromJson(json);

	Map<String, dynamic> toJson() => $LoginResponseProfileToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class LoginResponseProfileAddress {
	String? addressLine1 = '';
	String? addressLine2 = '';
	String? city = '';
	String? state = '';
	String? zip = '';
	String? country = '';
	String? type = '';

	LoginResponseProfileAddress();

	factory LoginResponseProfileAddress.fromJson(Map<String, dynamic> json) => $LoginResponseProfileAddressFromJson(json);

	Map<String, dynamic> toJson() => $LoginResponseProfileAddressToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class LoginResponseProfileWhatsapp {
	bool? instanceRedeem = false;
	bool? memberRedeem = false;
	bool? emailRedeem = false;
	@JSONField(name: '_id')
	String? id = '';

	LoginResponseProfileWhatsapp();

	factory LoginResponseProfileWhatsapp.fromJson(Map<String, dynamic> json) => $LoginResponseProfileWhatsappFromJson(json);

	Map<String, dynamic> toJson() => $LoginResponseProfileWhatsappToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class LoginResponseProfileSubscription {
	String? status = '';
	String? activateAt = '';
	String? expireAt = '';
	String? name = '';
	int? valid = 0;
	String? type = '';
	@JSONField(name: '_id')
	String? id = '';

	LoginResponseProfileSubscription();

	factory LoginResponseProfileSubscription.fromJson(Map<String, dynamic> json) => $LoginResponseProfileSubscriptionFromJson(json);

	Map<String, dynamic> toJson() => $LoginResponseProfileSubscriptionToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}