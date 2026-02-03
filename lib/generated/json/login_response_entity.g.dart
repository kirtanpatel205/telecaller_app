import 'package:telecaller_app/generated/json/base/json_convert_content.dart';
import 'package:telecaller_app/core/models/login_response_entity.dart';

LoginResponseEntity $LoginResponseEntityFromJson(Map<String, dynamic> json) {
  final LoginResponseEntity loginResponseEntity = LoginResponseEntity();
  final bool? status = jsonConvert.convert<bool>(json['status']);
  if (status != null) {
    loginResponseEntity.status = status;
  }
  final String? token = jsonConvert.convert<String>(json['token']);
  if (token != null) {
    loginResponseEntity.token = token;
  }
  final LoginResponseProfile? profile = jsonConvert.convert<
      LoginResponseProfile>(json['profile']);
  if (profile != null) {
    loginResponseEntity.profile = profile;
  }
  return loginResponseEntity;
}

Map<String, dynamic> $LoginResponseEntityToJson(LoginResponseEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['status'] = entity.status;
  data['token'] = entity.token;
  data['profile'] = entity.profile?.toJson();
  return data;
}

extension LoginResponseEntityExtension on LoginResponseEntity {
  LoginResponseEntity copyWith({
    bool? status,
    String? token,
    LoginResponseProfile? profile,
  }) {
    return LoginResponseEntity()
      ..status = status ?? this.status
      ..token = token ?? this.token
      ..profile = profile ?? this.profile;
  }
}

LoginResponseProfile $LoginResponseProfileFromJson(Map<String, dynamic> json) {
  final LoginResponseProfile loginResponseProfile = LoginResponseProfile();
  final LoginResponseProfileAddress? address = jsonConvert.convert<
      LoginResponseProfileAddress>(json['address']);
  if (address != null) {
    loginResponseProfile.address = address;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    loginResponseProfile.id = id;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    loginResponseProfile.name = name;
  }
  final String? authType = jsonConvert.convert<String>(json['authType']);
  if (authType != null) {
    loginResponseProfile.authType = authType;
  }
  final String? phone = jsonConvert.convert<String>(json['phone']);
  if (phone != null) {
    loginResponseProfile.phone = phone;
  }
  final String? profile = jsonConvert.convert<String>(json['profile']);
  if (profile != null) {
    loginResponseProfile.profile = profile;
  }
  final int? wallet = jsonConvert.convert<int>(json['wallet']);
  if (wallet != null) {
    loginResponseProfile.wallet = wallet;
  }
  final String? panelId = jsonConvert.convert<String>(json['panelId']);
  if (panelId != null) {
    loginResponseProfile.panelId = panelId;
  }
  final String? status = jsonConvert.convert<String>(json['status']);
  if (status != null) {
    loginResponseProfile.status = status;
  }
  final String? role = jsonConvert.convert<String>(json['role']);
  if (role != null) {
    loginResponseProfile.role = role;
  }
  final List<String>? assignedTo = (json['assignedTo'] as List<dynamic>?)?.map(
          (e) => jsonConvert.convert<String>(e) as String).toList();
  if (assignedTo != null) {
    loginResponseProfile.assignedTo = assignedTo;
  }
  final List<dynamic>? badge = (json['badge'] as List<dynamic>?)?.map(
          (e) => e).toList();
  if (badge != null) {
    loginResponseProfile.badge = badge;
  }
  final dynamic pin = json['pin'];
  if (pin != null) {
    loginResponseProfile.pin = pin;
  }
  final List<dynamic>? whiteList = (json['whiteList'] as List<dynamic>?)?.map(
          (e) => e).toList();
  if (whiteList != null) {
    loginResponseProfile.whiteList = whiteList;
  }
  final LoginResponseProfileWhatsapp? whatsapp = jsonConvert.convert<
      LoginResponseProfileWhatsapp>(json['whatsapp']);
  if (whatsapp != null) {
    loginResponseProfile.whatsapp = whatsapp;
  }
  final bool? telecallerRedeem = jsonConvert.convert<bool>(
      json['telecallerRedeem']);
  if (telecallerRedeem != null) {
    loginResponseProfile.telecallerRedeem = telecallerRedeem;
  }
  final List<dynamic>? sharedWith = (json['sharedWith'] as List<dynamic>?)?.map(
          (e) => e).toList();
  if (sharedWith != null) {
    loginResponseProfile.sharedWith = sharedWith;
  }
  final bool? rebrand = jsonConvert.convert<bool>(json['rebrand']);
  if (rebrand != null) {
    loginResponseProfile.rebrand = rebrand;
  }
  final List<dynamic>? rebrandProducts = (json['rebrandProducts'] as List<
      dynamic>?)?.map(
          (e) => e).toList();
  if (rebrandProducts != null) {
    loginResponseProfile.rebrandProducts = rebrandProducts;
  }
  final LoginResponseProfileSubscription? subscription = jsonConvert.convert<
      LoginResponseProfileSubscription>(json['subscription']);
  if (subscription != null) {
    loginResponseProfile.subscription = subscription;
  }
  final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
  if (createdAt != null) {
    loginResponseProfile.createdAt = createdAt;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    loginResponseProfile.updatedAt = updatedAt;
  }
  final int? v = jsonConvert.convert<int>(json['__v']);
  if (v != null) {
    loginResponseProfile.v = v;
  }
  final dynamic teamId = json['teamId'];
  if (teamId != null) {
    loginResponseProfile.teamId = teamId;
  }
  final String? email = jsonConvert.convert<String>(json['email']);
  if (email != null) {
    loginResponseProfile.email = email;
  }
  final String? lastLoginAt = jsonConvert.convert<String>(json['lastLoginAt']);
  if (lastLoginAt != null) {
    loginResponseProfile.lastLoginAt = lastLoginAt;
  }
  final String? fixOTP = jsonConvert.convert<String>(json['fixOTP']);
  if (fixOTP != null) {
    loginResponseProfile.fixOTP = fixOTP;
  }
  final String? fcmToken = jsonConvert.convert<String>(json['fcmToken']);
  if (fcmToken != null) {
    loginResponseProfile.fcmToken = fcmToken;
  }
  final int? otpVerify = jsonConvert.convert<int>(json['otpVerify']);
  if (otpVerify != null) {
    loginResponseProfile.otpVerify = otpVerify;
  }
  final int? otpSent = jsonConvert.convert<int>(json['otpSent']);
  if (otpSent != null) {
    loginResponseProfile.otpSent = otpSent;
  }
  return loginResponseProfile;
}

Map<String, dynamic> $LoginResponseProfileToJson(LoginResponseProfile entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['address'] = entity.address?.toJson();
  data['_id'] = entity.id;
  data['name'] = entity.name;
  data['authType'] = entity.authType;
  data['phone'] = entity.phone;
  data['profile'] = entity.profile;
  data['wallet'] = entity.wallet;
  data['panelId'] = entity.panelId;
  data['status'] = entity.status;
  data['role'] = entity.role;
  data['assignedTo'] = entity.assignedTo;
  data['badge'] = entity.badge;
  data['pin'] = entity.pin;
  data['whiteList'] = entity.whiteList;
  data['whatsapp'] = entity.whatsapp?.toJson();
  data['telecallerRedeem'] = entity.telecallerRedeem;
  data['sharedWith'] = entity.sharedWith;
  data['rebrand'] = entity.rebrand;
  data['rebrandProducts'] = entity.rebrandProducts;
  data['subscription'] = entity.subscription?.toJson();
  data['createdAt'] = entity.createdAt;
  data['updatedAt'] = entity.updatedAt;
  data['__v'] = entity.v;
  data['teamId'] = entity.teamId;
  data['email'] = entity.email;
  data['lastLoginAt'] = entity.lastLoginAt;
  data['fixOTP'] = entity.fixOTP;
  data['fcmToken'] = entity.fcmToken;
  data['otpVerify'] = entity.otpVerify;
  data['otpSent'] = entity.otpSent;
  return data;
}

extension LoginResponseProfileExtension on LoginResponseProfile {
  LoginResponseProfile copyWith({
    LoginResponseProfileAddress? address,
    String? id,
    String? name,
    String? authType,
    String? phone,
    String? profile,
    int? wallet,
    String? panelId,
    String? status,
    String? role,
    List<String>? assignedTo,
    List<dynamic>? badge,
    dynamic pin,
    List<dynamic>? whiteList,
    LoginResponseProfileWhatsapp? whatsapp,
    bool? telecallerRedeem,
    List<dynamic>? sharedWith,
    bool? rebrand,
    List<dynamic>? rebrandProducts,
    LoginResponseProfileSubscription? subscription,
    String? createdAt,
    String? updatedAt,
    int? v,
    dynamic teamId,
    String? email,
    String? lastLoginAt,
    String? fixOTP,
    String? fcmToken,
    int? otpVerify,
    int? otpSent,
  }) {
    return LoginResponseProfile()
      ..address = address ?? this.address
      ..id = id ?? this.id
      ..name = name ?? this.name
      ..authType = authType ?? this.authType
      ..phone = phone ?? this.phone
      ..profile = profile ?? this.profile
      ..wallet = wallet ?? this.wallet
      ..panelId = panelId ?? this.panelId
      ..status = status ?? this.status
      ..role = role ?? this.role
      ..assignedTo = assignedTo ?? this.assignedTo
      ..badge = badge ?? this.badge
      ..pin = pin ?? this.pin
      ..whiteList = whiteList ?? this.whiteList
      ..whatsapp = whatsapp ?? this.whatsapp
      ..telecallerRedeem = telecallerRedeem ?? this.telecallerRedeem
      ..sharedWith = sharedWith ?? this.sharedWith
      ..rebrand = rebrand ?? this.rebrand
      ..rebrandProducts = rebrandProducts ?? this.rebrandProducts
      ..subscription = subscription ?? this.subscription
      ..createdAt = createdAt ?? this.createdAt
      ..updatedAt = updatedAt ?? this.updatedAt
      ..v = v ?? this.v
      ..teamId = teamId ?? this.teamId
      ..email = email ?? this.email
      ..lastLoginAt = lastLoginAt ?? this.lastLoginAt
      ..fixOTP = fixOTP ?? this.fixOTP
      ..fcmToken = fcmToken ?? this.fcmToken
      ..otpVerify = otpVerify ?? this.otpVerify
      ..otpSent = otpSent ?? this.otpSent;
  }
}

LoginResponseProfileAddress $LoginResponseProfileAddressFromJson(
    Map<String, dynamic> json) {
  final LoginResponseProfileAddress loginResponseProfileAddress = LoginResponseProfileAddress();
  final String? addressLine1 = jsonConvert.convert<String>(
      json['addressLine1']);
  if (addressLine1 != null) {
    loginResponseProfileAddress.addressLine1 = addressLine1;
  }
  final String? addressLine2 = jsonConvert.convert<String>(
      json['addressLine2']);
  if (addressLine2 != null) {
    loginResponseProfileAddress.addressLine2 = addressLine2;
  }
  final String? city = jsonConvert.convert<String>(json['city']);
  if (city != null) {
    loginResponseProfileAddress.city = city;
  }
  final String? state = jsonConvert.convert<String>(json['state']);
  if (state != null) {
    loginResponseProfileAddress.state = state;
  }
  final String? zip = jsonConvert.convert<String>(json['zip']);
  if (zip != null) {
    loginResponseProfileAddress.zip = zip;
  }
  final String? country = jsonConvert.convert<String>(json['country']);
  if (country != null) {
    loginResponseProfileAddress.country = country;
  }
  final String? type = jsonConvert.convert<String>(json['type']);
  if (type != null) {
    loginResponseProfileAddress.type = type;
  }
  return loginResponseProfileAddress;
}

Map<String, dynamic> $LoginResponseProfileAddressToJson(
    LoginResponseProfileAddress entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['addressLine1'] = entity.addressLine1;
  data['addressLine2'] = entity.addressLine2;
  data['city'] = entity.city;
  data['state'] = entity.state;
  data['zip'] = entity.zip;
  data['country'] = entity.country;
  data['type'] = entity.type;
  return data;
}

extension LoginResponseProfileAddressExtension on LoginResponseProfileAddress {
  LoginResponseProfileAddress copyWith({
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? zip,
    String? country,
    String? type,
  }) {
    return LoginResponseProfileAddress()
      ..addressLine1 = addressLine1 ?? this.addressLine1
      ..addressLine2 = addressLine2 ?? this.addressLine2
      ..city = city ?? this.city
      ..state = state ?? this.state
      ..zip = zip ?? this.zip
      ..country = country ?? this.country
      ..type = type ?? this.type;
  }
}

LoginResponseProfileWhatsapp $LoginResponseProfileWhatsappFromJson(
    Map<String, dynamic> json) {
  final LoginResponseProfileWhatsapp loginResponseProfileWhatsapp = LoginResponseProfileWhatsapp();
  final bool? instanceRedeem = jsonConvert.convert<bool>(
      json['instanceRedeem']);
  if (instanceRedeem != null) {
    loginResponseProfileWhatsapp.instanceRedeem = instanceRedeem;
  }
  final bool? memberRedeem = jsonConvert.convert<bool>(json['memberRedeem']);
  if (memberRedeem != null) {
    loginResponseProfileWhatsapp.memberRedeem = memberRedeem;
  }
  final bool? emailRedeem = jsonConvert.convert<bool>(json['emailRedeem']);
  if (emailRedeem != null) {
    loginResponseProfileWhatsapp.emailRedeem = emailRedeem;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    loginResponseProfileWhatsapp.id = id;
  }
  return loginResponseProfileWhatsapp;
}

Map<String, dynamic> $LoginResponseProfileWhatsappToJson(
    LoginResponseProfileWhatsapp entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['instanceRedeem'] = entity.instanceRedeem;
  data['memberRedeem'] = entity.memberRedeem;
  data['emailRedeem'] = entity.emailRedeem;
  data['_id'] = entity.id;
  return data;
}

extension LoginResponseProfileWhatsappExtension on LoginResponseProfileWhatsapp {
  LoginResponseProfileWhatsapp copyWith({
    bool? instanceRedeem,
    bool? memberRedeem,
    bool? emailRedeem,
    String? id,
  }) {
    return LoginResponseProfileWhatsapp()
      ..instanceRedeem = instanceRedeem ?? this.instanceRedeem
      ..memberRedeem = memberRedeem ?? this.memberRedeem
      ..emailRedeem = emailRedeem ?? this.emailRedeem
      ..id = id ?? this.id;
  }
}

LoginResponseProfileSubscription $LoginResponseProfileSubscriptionFromJson(
    Map<String, dynamic> json) {
  final LoginResponseProfileSubscription loginResponseProfileSubscription = LoginResponseProfileSubscription();
  final String? status = jsonConvert.convert<String>(json['status']);
  if (status != null) {
    loginResponseProfileSubscription.status = status;
  }
  final String? activateAt = jsonConvert.convert<String>(json['activateAt']);
  if (activateAt != null) {
    loginResponseProfileSubscription.activateAt = activateAt;
  }
  final String? expireAt = jsonConvert.convert<String>(json['expireAt']);
  if (expireAt != null) {
    loginResponseProfileSubscription.expireAt = expireAt;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    loginResponseProfileSubscription.name = name;
  }
  final int? valid = jsonConvert.convert<int>(json['valid']);
  if (valid != null) {
    loginResponseProfileSubscription.valid = valid;
  }
  final String? type = jsonConvert.convert<String>(json['type']);
  if (type != null) {
    loginResponseProfileSubscription.type = type;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    loginResponseProfileSubscription.id = id;
  }
  return loginResponseProfileSubscription;
}

Map<String, dynamic> $LoginResponseProfileSubscriptionToJson(
    LoginResponseProfileSubscription entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['status'] = entity.status;
  data['activateAt'] = entity.activateAt;
  data['expireAt'] = entity.expireAt;
  data['name'] = entity.name;
  data['valid'] = entity.valid;
  data['type'] = entity.type;
  data['_id'] = entity.id;
  return data;
}

extension LoginResponseProfileSubscriptionExtension on LoginResponseProfileSubscription {
  LoginResponseProfileSubscription copyWith({
    String? status,
    String? activateAt,
    String? expireAt,
    String? name,
    int? valid,
    String? type,
    String? id,
  }) {
    return LoginResponseProfileSubscription()
      ..status = status ?? this.status
      ..activateAt = activateAt ?? this.activateAt
      ..expireAt = expireAt ?? this.expireAt
      ..name = name ?? this.name
      ..valid = valid ?? this.valid
      ..type = type ?? this.type
      ..id = id ?? this.id;
  }
}