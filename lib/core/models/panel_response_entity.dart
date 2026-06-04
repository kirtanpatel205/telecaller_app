import 'package:telecaller_app/generated/json/base/json_field.dart';
import 'package:telecaller_app/generated/json/panel_response_entity.g.dart';
import 'dart:convert';
export 'package:telecaller_app/generated/json/panel_response_entity.g.dart';

@JsonSerializable()
class PanelResponseEntity {
	bool? status = false;
	PanelResponsePanel? panel;

	PanelResponseEntity();

	factory PanelResponseEntity.fromJson(Map<String, dynamic> json) => $PanelResponseEntityFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponseEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanel {
	PanelResponsePanelPaymentGateway? paymentGateway;
	dynamic bannedMessage;
	@JSONField(name: '_id')
	String? id = '';
	String? name = '';
	String? domain = '';
	String? defaultCurrency = '';
	String? website = '';
	String? userId = '';
	String? status = '';
	PanelResponsePanelSeo? seo;
	PanelResponsePanelBilling? billing;
	PanelResponsePanelGoogleTag? googleTag;
	PanelResponsePanelPolicy? policy;
	List<PanelResponsePanelCurrencies>? currencies = [];
	String? createdAt = '';
	String? updatedAt = '';
	@JSONField(name: '__v')
	int? v = 0;
	PanelResponsePanelGithub? github;
	PanelResponsePanelCrm? crm;
	PanelResponsePanelTelecaller? telecaller;
	PanelResponsePanelCost? cost;

	PanelResponsePanel();

	factory PanelResponsePanel.fromJson(Map<String, dynamic> json) => $PanelResponsePanelFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelPaymentGateway {
	PanelResponsePanelPaymentGatewayRazorPay? razorPay;
	PanelResponsePanelPaymentGatewayPayPal? payPal;
	PanelResponsePanelPaymentGatewayPhonePe? phonePe;
	PanelResponsePanelPaymentGatewayPayUMoney? payUMoney;
	PanelResponsePanelPaymentGatewayCashfree? cashfree;
	PanelResponsePanelPaymentGatewaySmepay? smepay;

	PanelResponsePanelPaymentGateway();

	factory PanelResponsePanelPaymentGateway.fromJson(Map<String, dynamic> json) => $PanelResponsePanelPaymentGatewayFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelPaymentGatewayToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelPaymentGatewayRazorPay {
	String? keyId = '';
	String? keySecret = '';
	String? webhookSecret = '';
	int? charge = 0;
	bool? enable = false;
	String? updatedAt = '';
	@JSONField(name: '_id')
	String? id = '';

	PanelResponsePanelPaymentGatewayRazorPay();

	factory PanelResponsePanelPaymentGatewayRazorPay.fromJson(Map<String, dynamic> json) => $PanelResponsePanelPaymentGatewayRazorPayFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelPaymentGatewayRazorPayToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelPaymentGatewayPayPal {
	String? email = '';
	String? clientId = '';
	String? secretKey = '';
	int? charge = 0;
	bool? enable = false;
	String? updatedAt = '';
	@JSONField(name: '_id')
	String? id = '';

	PanelResponsePanelPaymentGatewayPayPal();

	factory PanelResponsePanelPaymentGatewayPayPal.fromJson(Map<String, dynamic> json) => $PanelResponsePanelPaymentGatewayPayPalFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelPaymentGatewayPayPalToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelPaymentGatewayPhonePe {
	String? merchantId = '';
	String? saltKey = '';
	int? charge = 0;
	bool? enable = false;
	@JSONField(name: '_id')
	String? id = '';
	String? updatedAt = '';

	PanelResponsePanelPaymentGatewayPhonePe();

	factory PanelResponsePanelPaymentGatewayPhonePe.fromJson(Map<String, dynamic> json) => $PanelResponsePanelPaymentGatewayPhonePeFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelPaymentGatewayPhonePeToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelPaymentGatewayPayUMoney {
	String? merchantKey = '';
	String? merchantSalt = '';
	int? charge = 0;
	bool? enable = false;
	@JSONField(name: '_id')
	String? id = '';
	String? updatedAt = '';

	PanelResponsePanelPaymentGatewayPayUMoney();

	factory PanelResponsePanelPaymentGatewayPayUMoney.fromJson(Map<String, dynamic> json) => $PanelResponsePanelPaymentGatewayPayUMoneyFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelPaymentGatewayPayUMoneyToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelPaymentGatewayCashfree {
	String? appId = '';
	String? secretKey = '';
	String? env = '';
	int? charge = 0;
	String? apiVersion = '';
	bool? enable = false;
	String? webhookSignature = '';
	@JSONField(name: '_id')
	String? id = '';
	String? updatedAt = '';

	PanelResponsePanelPaymentGatewayCashfree();

	factory PanelResponsePanelPaymentGatewayCashfree.fromJson(Map<String, dynamic> json) => $PanelResponsePanelPaymentGatewayCashfreeFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelPaymentGatewayCashfreeToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelPaymentGatewaySmepay {
	@JSONField(name: 'client_id')
	String? clientId = '';
	@JSONField(name: 'client_secret')
	String? clientSecret = '';
	int? charge = 0;
	bool? enable = false;
	String? updatedAt = '';
	@JSONField(name: '_id')
	String? id = '';

	PanelResponsePanelPaymentGatewaySmepay();

	factory PanelResponsePanelPaymentGatewaySmepay.fromJson(Map<String, dynamic> json) => $PanelResponsePanelPaymentGatewaySmepayFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelPaymentGatewaySmepayToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelSeo {
	String? title = '';
	String? description = '';
	String? keywords = '';
	String? image = '';
	String? updatedAt = '';
	@JSONField(name: '_id')
	String? id = '';

	PanelResponsePanelSeo();

	factory PanelResponsePanelSeo.fromJson(Map<String, dynamic> json) => $PanelResponsePanelSeoFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelSeoToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelBilling {
	String? name = '';
	String? email = '';
	String? phone = '';
	String? gstNumber = '';
	String? address = '';
	String? logo = '';
	String? updatedAt = '';
	@JSONField(name: '_id')
	String? id = '';

	PanelResponsePanelBilling();

	factory PanelResponsePanelBilling.fromJson(Map<String, dynamic> json) => $PanelResponsePanelBillingFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelBillingToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelGoogleTag {
	String? tagManagerId = '';
	String? merchantId = '';
	String? updatedAt = '';
	@JSONField(name: '_id')
	String? id = '';

	PanelResponsePanelGoogleTag();

	factory PanelResponsePanelGoogleTag.fromJson(Map<String, dynamic> json) => $PanelResponsePanelGoogleTagFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelGoogleTagToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelPolicy {
	String? termsAndConditions = '';
	String? privacyPolicy = '';
	String? refundPolicy = '';
	@JSONField(name: '_id')
	String? id = '';
	String? updatedAt = '';

	PanelResponsePanelPolicy();

	factory PanelResponsePanelPolicy.fromJson(Map<String, dynamic> json) => $PanelResponsePanelPolicyFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelPolicyToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelCurrencies {
	int? position = 0;
	bool? enable = false;
	String? code = '';
	List<String>? countries = [];
	List<String>? paymentGateways = [];
	@JSONField(name: '_id')
	String? id = '';

	PanelResponsePanelCurrencies();

	factory PanelResponsePanelCurrencies.fromJson(Map<String, dynamic> json) => $PanelResponsePanelCurrenciesFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelCurrenciesToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelGithub {
	String? username = '';
	String? token = '';
	bool? enable = false;
	String? updatedAt = '';
	@JSONField(name: '_id')
	String? id = '';

	PanelResponsePanelGithub();

	factory PanelResponsePanelGithub.fromJson(Map<String, dynamic> json) => $PanelResponsePanelGithubFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelGithubToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelCrm {
	PanelResponsePanelCrmSupport? support;
	bool? enable = false;
	String? domain = '';
	bool? dns = false;
	bool? ssl = false;
	String? name = '';
	String? description = '';
	String? slogan = '';
	String? favicon = '';
	String? logo = '';
	String? logoLong = '';
	String? phone = '';
	String? email = '';
	String? address = '';
	String? country = '';
	String? dialCode = '';
	String? language = '';
	PanelResponsePanelCrmSocialMedia? socialMedia;
	PanelResponsePanelCrmTheme? theme;
	PanelResponsePanelCrmCarousel? carousel;
	PanelResponsePanelCrmRate? rate;
	String? updatedAt = '';
	@JSONField(name: '_id')
	String? id = '';

	PanelResponsePanelCrm();

	factory PanelResponsePanelCrm.fromJson(Map<String, dynamic> json) => $PanelResponsePanelCrmFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelCrmToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelCrmSupport {
	List<dynamic>? whatsApp = [];

	PanelResponsePanelCrmSupport();

	factory PanelResponsePanelCrmSupport.fromJson(Map<String, dynamic> json) => $PanelResponsePanelCrmSupportFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelCrmSupportToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelCrmSocialMedia {
	String? facebook = '';
	String? instagram = '';
	String? twitter = '';
	String? linkedin = '';
	String? youtube = '';
	String? updatedAt = '';
	@JSONField(name: '_id')
	String? id = '';

	PanelResponsePanelCrmSocialMedia();

	factory PanelResponsePanelCrmSocialMedia.fromJson(Map<String, dynamic> json) => $PanelResponsePanelCrmSocialMediaFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelCrmSocialMediaToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelCrmTheme {
	PanelResponsePanelCrmThemeToken? token;
	String? algorithm = '';

	PanelResponsePanelCrmTheme();

	factory PanelResponsePanelCrmTheme.fromJson(Map<String, dynamic> json) => $PanelResponsePanelCrmThemeFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelCrmThemeToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelCrmThemeToken {
	String? colorPrimary = '';
	int? borderRadius = 0;

	PanelResponsePanelCrmThemeToken();

	factory PanelResponsePanelCrmThemeToken.fromJson(Map<String, dynamic> json) => $PanelResponsePanelCrmThemeTokenFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelCrmThemeTokenToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelCrmCarousel {
	bool? enable = false;
	String? image = '';
	String? link = '';
	List<dynamic>? items = [];
	@JSONField(name: '_id')
	String? id = '';

	PanelResponsePanelCrmCarousel();

	factory PanelResponsePanelCrmCarousel.fromJson(Map<String, dynamic> json) => $PanelResponsePanelCrmCarouselFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelCrmCarouselToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelCrmRate {
	PanelResponsePanelCrmRateUser? user;
	PanelResponsePanelCrmRateMaster? master;

	PanelResponsePanelCrmRate();

	factory PanelResponsePanelCrmRate.fromJson(Map<String, dynamic> json) => $PanelResponsePanelCrmRateFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelCrmRateToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelCrmRateUser {
	List<PanelResponsePanelCrmRateUserInstance>? instance = [];
	List<PanelResponsePanelCrmRateUserMember>? member = [];
	List<PanelResponsePanelCrmRateUserEmail>? email = [];
	List<PanelResponsePanelCrmRateUserTelecaller>? telecaller = [];

	PanelResponsePanelCrmRateUser();

	factory PanelResponsePanelCrmRateUser.fromJson(Map<String, dynamic> json) => $PanelResponsePanelCrmRateUserFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelCrmRateUserToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelCrmRateUserInstance {
	bool? enable = false;
	String? name = '';
	int? price = 0;
	int? valid = 0;
	String? updatedAt = '';
	@JSONField(name: '_id')
	String? id = '';

	PanelResponsePanelCrmRateUserInstance();

	factory PanelResponsePanelCrmRateUserInstance.fromJson(Map<String, dynamic> json) => $PanelResponsePanelCrmRateUserInstanceFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelCrmRateUserInstanceToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelCrmRateUserMember {
	bool? enable = false;
	String? name = '';
	int? price = 0;
	int? valid = 0;
	String? updatedAt = '';
	@JSONField(name: '_id')
	String? id = '';

	PanelResponsePanelCrmRateUserMember();

	factory PanelResponsePanelCrmRateUserMember.fromJson(Map<String, dynamic> json) => $PanelResponsePanelCrmRateUserMemberFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelCrmRateUserMemberToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelCrmRateUserEmail {
	bool? enable = false;
	String? name = '';
	int? price = 0;
	int? valid = 0;
	String? updatedAt = '';
	@JSONField(name: '_id')
	String? id = '';

	PanelResponsePanelCrmRateUserEmail();

	factory PanelResponsePanelCrmRateUserEmail.fromJson(Map<String, dynamic> json) => $PanelResponsePanelCrmRateUserEmailFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelCrmRateUserEmailToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelCrmRateUserTelecaller {
	bool? enable = false;
	String? name = '';
	int? price = 0;
	int? valid = 0;
	String? updatedAt = '';
	@JSONField(name: '_id')
	String? id = '';

	PanelResponsePanelCrmRateUserTelecaller();

	factory PanelResponsePanelCrmRateUserTelecaller.fromJson(Map<String, dynamic> json) => $PanelResponsePanelCrmRateUserTelecallerFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelCrmRateUserTelecallerToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelCrmRateMaster {
	List<PanelResponsePanelCrmRateMasterMember>? member = [];
	List<PanelResponsePanelCrmRateMasterInstance>? instance = [];
	List<PanelResponsePanelCrmRateMasterEmail>? email = [];
	List<PanelResponsePanelCrmRateMasterTelecaller>? telecaller = [];

	PanelResponsePanelCrmRateMaster();

	factory PanelResponsePanelCrmRateMaster.fromJson(Map<String, dynamic> json) => $PanelResponsePanelCrmRateMasterFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelCrmRateMasterToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelCrmRateMasterMember {
	@JSONField(name: '_id')
	String? id = '';
	String? name = '';
	int? price = 0;
	int? valid = 0;
	String? createdAt = '';
	String? updatedAt = '';

	PanelResponsePanelCrmRateMasterMember();

	factory PanelResponsePanelCrmRateMasterMember.fromJson(Map<String, dynamic> json) => $PanelResponsePanelCrmRateMasterMemberFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelCrmRateMasterMemberToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelCrmRateMasterInstance {
	@JSONField(name: '_id')
	String? id = '';
	String? name = '';
	int? price = 0;
	int? valid = 0;
	String? createdAt = '';
	String? updatedAt = '';

	PanelResponsePanelCrmRateMasterInstance();

	factory PanelResponsePanelCrmRateMasterInstance.fromJson(Map<String, dynamic> json) => $PanelResponsePanelCrmRateMasterInstanceFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelCrmRateMasterInstanceToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelCrmRateMasterEmail {
	@JSONField(name: '_id')
	String? id = '';
	String? name = '';
	int? price = 0;
	int? valid = 0;
	String? createdAt = '';
	String? updatedAt = '';

	PanelResponsePanelCrmRateMasterEmail();

	factory PanelResponsePanelCrmRateMasterEmail.fromJson(Map<String, dynamic> json) => $PanelResponsePanelCrmRateMasterEmailFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelCrmRateMasterEmailToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelCrmRateMasterTelecaller {
	@JSONField(name: '_id')
	String? id = '';
	String? name = '';
	int? price = 0;
	int? valid = 0;
	String? createdAt = '';
	String? updatedAt = '';

	PanelResponsePanelCrmRateMasterTelecaller();

	factory PanelResponsePanelCrmRateMasterTelecaller.fromJson(Map<String, dynamic> json) => $PanelResponsePanelCrmRateMasterTelecallerFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelCrmRateMasterTelecallerToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelTelecaller {
	PanelResponsePanelTelecallerSupport? support;
	bool? enable = false;
	String? domain = '';
	bool? dns = false;
	bool? ssl = false;
	String? name = '';
	String? description = '';
	String? slogan = '';
	String? favicon = '';
	String? logo = '';
	String? logoLong = '';
	String? phone = '';
	String? email = '';
	String? address = '';
	String? country = '';
	String? dialCode = '';
	String? language = '';
	PanelResponsePanelTelecallerSocialMedia? socialMedia;
	PanelResponsePanelTelecallerTheme? theme;
	PanelResponsePanelTelecallerCarousel? carousel;
	String? updatedAt = '';
	@JSONField(name: '_id')
	String? id = '';

	PanelResponsePanelTelecaller();

	factory PanelResponsePanelTelecaller.fromJson(Map<String, dynamic> json) => $PanelResponsePanelTelecallerFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelTelecallerToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelTelecallerSupport {
	List<dynamic>? whatsApp = [];

	PanelResponsePanelTelecallerSupport();

	factory PanelResponsePanelTelecallerSupport.fromJson(Map<String, dynamic> json) => $PanelResponsePanelTelecallerSupportFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelTelecallerSupportToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelTelecallerSocialMedia {
	String? facebook = '';
	String? instagram = '';
	String? twitter = '';
	String? linkedin = '';
	String? youtube = '';
	String? updatedAt = '';
	@JSONField(name: '_id')
	String? id = '';

	PanelResponsePanelTelecallerSocialMedia();

	factory PanelResponsePanelTelecallerSocialMedia.fromJson(Map<String, dynamic> json) => $PanelResponsePanelTelecallerSocialMediaFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelTelecallerSocialMediaToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelTelecallerTheme {
	String? algorithm = '';
	PanelResponsePanelTelecallerThemeToken? token;

	PanelResponsePanelTelecallerTheme();

	factory PanelResponsePanelTelecallerTheme.fromJson(Map<String, dynamic> json) => $PanelResponsePanelTelecallerThemeFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelTelecallerThemeToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelTelecallerThemeToken {
	String? colorPrimary = '';
	int? borderRadius = 0;

	PanelResponsePanelTelecallerThemeToken();

	factory PanelResponsePanelTelecallerThemeToken.fromJson(Map<String, dynamic> json) => $PanelResponsePanelTelecallerThemeTokenFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelTelecallerThemeTokenToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelTelecallerCarousel {
	bool? enable = false;
	String? image = '';
	String? link = '';
	List<dynamic>? items = [];
	@JSONField(name: '_id')
	String? id = '';

	PanelResponsePanelTelecallerCarousel();

	factory PanelResponsePanelTelecallerCarousel.fromJson(Map<String, dynamic> json) => $PanelResponsePanelTelecallerCarouselFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelTelecallerCarouselToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelCost {
	int? removeDevice = 0;
	int? masterOnboarding = 0;
	List<PanelResponsePanelCostRebranding>? rebranding = [];
	int? rebrandingLicense = 0;

	PanelResponsePanelCost();

	factory PanelResponsePanelCost.fromJson(Map<String, dynamic> json) => $PanelResponsePanelCostFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelCostToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class PanelResponsePanelCostRebranding {
	String? productId = '';
	int? cost = 0;

	PanelResponsePanelCostRebranding();

	factory PanelResponsePanelCostRebranding.fromJson(Map<String, dynamic> json) => $PanelResponsePanelCostRebrandingFromJson(json);

	Map<String, dynamic> toJson() => $PanelResponsePanelCostRebrandingToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}