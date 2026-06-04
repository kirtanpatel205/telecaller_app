import 'package:telecaller_app/generated/json/base/json_convert_content.dart';
import 'package:telecaller_app/core/models/panel_response_entity.dart';

PanelResponseEntity $PanelResponseEntityFromJson(Map<String, dynamic> json) {
  final PanelResponseEntity panelResponseEntity = PanelResponseEntity();
  final bool? status = jsonConvert.convert<bool>(json['status']);
  if (status != null) {
    panelResponseEntity.status = status;
  }
  final PanelResponsePanel? panel = jsonConvert.convert<PanelResponsePanel>(
      json['panel']);
  if (panel != null) {
    panelResponseEntity.panel = panel;
  }
  return panelResponseEntity;
}

Map<String, dynamic> $PanelResponseEntityToJson(PanelResponseEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['status'] = entity.status;
  data['panel'] = entity.panel?.toJson();
  return data;
}

extension PanelResponseEntityExtension on PanelResponseEntity {
  PanelResponseEntity copyWith({
    bool? status,
    PanelResponsePanel? panel,
  }) {
    return PanelResponseEntity()
      ..status = status ?? this.status
      ..panel = panel ?? this.panel;
  }
}

PanelResponsePanel $PanelResponsePanelFromJson(Map<String, dynamic> json) {
  final PanelResponsePanel panelResponsePanel = PanelResponsePanel();
  final PanelResponsePanelPaymentGateway? paymentGateway = jsonConvert.convert<
      PanelResponsePanelPaymentGateway>(json['paymentGateway']);
  if (paymentGateway != null) {
    panelResponsePanel.paymentGateway = paymentGateway;
  }
  final dynamic bannedMessage = json['bannedMessage'];
  if (bannedMessage != null) {
    panelResponsePanel.bannedMessage = bannedMessage;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    panelResponsePanel.id = id;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    panelResponsePanel.name = name;
  }
  final String? domain = jsonConvert.convert<String>(json['domain']);
  if (domain != null) {
    panelResponsePanel.domain = domain;
  }
  final String? defaultCurrency = jsonConvert.convert<String>(
      json['defaultCurrency']);
  if (defaultCurrency != null) {
    panelResponsePanel.defaultCurrency = defaultCurrency;
  }
  final String? website = jsonConvert.convert<String>(json['website']);
  if (website != null) {
    panelResponsePanel.website = website;
  }
  final String? userId = jsonConvert.convert<String>(json['userId']);
  if (userId != null) {
    panelResponsePanel.userId = userId;
  }
  final String? status = jsonConvert.convert<String>(json['status']);
  if (status != null) {
    panelResponsePanel.status = status;
  }
  final PanelResponsePanelSeo? seo = jsonConvert.convert<PanelResponsePanelSeo>(
      json['seo']);
  if (seo != null) {
    panelResponsePanel.seo = seo;
  }
  final PanelResponsePanelBilling? billing = jsonConvert.convert<
      PanelResponsePanelBilling>(json['billing']);
  if (billing != null) {
    panelResponsePanel.billing = billing;
  }
  final PanelResponsePanelGoogleTag? googleTag = jsonConvert.convert<
      PanelResponsePanelGoogleTag>(json['googleTag']);
  if (googleTag != null) {
    panelResponsePanel.googleTag = googleTag;
  }
  final PanelResponsePanelPolicy? policy = jsonConvert.convert<
      PanelResponsePanelPolicy>(json['policy']);
  if (policy != null) {
    panelResponsePanel.policy = policy;
  }
  final List<
      PanelResponsePanelCurrencies>? currencies = (json['currencies'] as List<
      dynamic>?)?.map(
          (e) =>
      jsonConvert.convert<PanelResponsePanelCurrencies>(
          e) as PanelResponsePanelCurrencies).toList();
  if (currencies != null) {
    panelResponsePanel.currencies = currencies;
  }
  final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
  if (createdAt != null) {
    panelResponsePanel.createdAt = createdAt;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    panelResponsePanel.updatedAt = updatedAt;
  }
  final int? v = jsonConvert.convert<int>(json['__v']);
  if (v != null) {
    panelResponsePanel.v = v;
  }
  final PanelResponsePanelGithub? github = jsonConvert.convert<
      PanelResponsePanelGithub>(json['github']);
  if (github != null) {
    panelResponsePanel.github = github;
  }
  final PanelResponsePanelCrm? crm = jsonConvert.convert<PanelResponsePanelCrm>(
      json['crm']);
  if (crm != null) {
    panelResponsePanel.crm = crm;
  }
  final PanelResponsePanelTelecaller? telecaller = jsonConvert.convert<
      PanelResponsePanelTelecaller>(json['telecaller']);
  if (telecaller != null) {
    panelResponsePanel.telecaller = telecaller;
  }
  final PanelResponsePanelCost? cost = jsonConvert.convert<
      PanelResponsePanelCost>(json['cost']);
  if (cost != null) {
    panelResponsePanel.cost = cost;
  }
  return panelResponsePanel;
}

Map<String, dynamic> $PanelResponsePanelToJson(PanelResponsePanel entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['paymentGateway'] = entity.paymentGateway?.toJson();
  data['bannedMessage'] = entity.bannedMessage;
  data['_id'] = entity.id;
  data['name'] = entity.name;
  data['domain'] = entity.domain;
  data['defaultCurrency'] = entity.defaultCurrency;
  data['website'] = entity.website;
  data['userId'] = entity.userId;
  data['status'] = entity.status;
  data['seo'] = entity.seo?.toJson();
  data['billing'] = entity.billing?.toJson();
  data['googleTag'] = entity.googleTag?.toJson();
  data['policy'] = entity.policy?.toJson();
  data['currencies'] = entity.currencies?.map((v) => v.toJson()).toList();
  data['createdAt'] = entity.createdAt;
  data['updatedAt'] = entity.updatedAt;
  data['__v'] = entity.v;
  data['github'] = entity.github?.toJson();
  data['crm'] = entity.crm?.toJson();
  data['telecaller'] = entity.telecaller?.toJson();
  data['cost'] = entity.cost?.toJson();
  return data;
}

extension PanelResponsePanelExtension on PanelResponsePanel {
  PanelResponsePanel copyWith({
    PanelResponsePanelPaymentGateway? paymentGateway,
    dynamic bannedMessage,
    String? id,
    String? name,
    String? domain,
    String? defaultCurrency,
    String? website,
    String? userId,
    String? status,
    PanelResponsePanelSeo? seo,
    PanelResponsePanelBilling? billing,
    PanelResponsePanelGoogleTag? googleTag,
    PanelResponsePanelPolicy? policy,
    List<PanelResponsePanelCurrencies>? currencies,
    String? createdAt,
    String? updatedAt,
    int? v,
    PanelResponsePanelGithub? github,
    PanelResponsePanelCrm? crm,
    PanelResponsePanelTelecaller? telecaller,
    PanelResponsePanelCost? cost,
  }) {
    return PanelResponsePanel()
      ..paymentGateway = paymentGateway ?? this.paymentGateway
      ..bannedMessage = bannedMessage ?? this.bannedMessage
      ..id = id ?? this.id
      ..name = name ?? this.name
      ..domain = domain ?? this.domain
      ..defaultCurrency = defaultCurrency ?? this.defaultCurrency
      ..website = website ?? this.website
      ..userId = userId ?? this.userId
      ..status = status ?? this.status
      ..seo = seo ?? this.seo
      ..billing = billing ?? this.billing
      ..googleTag = googleTag ?? this.googleTag
      ..policy = policy ?? this.policy
      ..currencies = currencies ?? this.currencies
      ..createdAt = createdAt ?? this.createdAt
      ..updatedAt = updatedAt ?? this.updatedAt
      ..v = v ?? this.v
      ..github = github ?? this.github
      ..crm = crm ?? this.crm
      ..telecaller = telecaller ?? this.telecaller
      ..cost = cost ?? this.cost;
  }
}

PanelResponsePanelPaymentGateway $PanelResponsePanelPaymentGatewayFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelPaymentGateway panelResponsePanelPaymentGateway = PanelResponsePanelPaymentGateway();
  final PanelResponsePanelPaymentGatewayRazorPay? razorPay = jsonConvert
      .convert<PanelResponsePanelPaymentGatewayRazorPay>(json['razorPay']);
  if (razorPay != null) {
    panelResponsePanelPaymentGateway.razorPay = razorPay;
  }
  final PanelResponsePanelPaymentGatewayPayPal? payPal = jsonConvert.convert<
      PanelResponsePanelPaymentGatewayPayPal>(json['payPal']);
  if (payPal != null) {
    panelResponsePanelPaymentGateway.payPal = payPal;
  }
  final PanelResponsePanelPaymentGatewayPhonePe? phonePe = jsonConvert.convert<
      PanelResponsePanelPaymentGatewayPhonePe>(json['phonePe']);
  if (phonePe != null) {
    panelResponsePanelPaymentGateway.phonePe = phonePe;
  }
  final PanelResponsePanelPaymentGatewayPayUMoney? payUMoney = jsonConvert
      .convert<PanelResponsePanelPaymentGatewayPayUMoney>(json['payUMoney']);
  if (payUMoney != null) {
    panelResponsePanelPaymentGateway.payUMoney = payUMoney;
  }
  final PanelResponsePanelPaymentGatewayCashfree? cashfree = jsonConvert
      .convert<PanelResponsePanelPaymentGatewayCashfree>(json['cashfree']);
  if (cashfree != null) {
    panelResponsePanelPaymentGateway.cashfree = cashfree;
  }
  final PanelResponsePanelPaymentGatewaySmepay? smepay = jsonConvert.convert<
      PanelResponsePanelPaymentGatewaySmepay>(json['smepay']);
  if (smepay != null) {
    panelResponsePanelPaymentGateway.smepay = smepay;
  }
  return panelResponsePanelPaymentGateway;
}

Map<String, dynamic> $PanelResponsePanelPaymentGatewayToJson(
    PanelResponsePanelPaymentGateway entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['razorPay'] = entity.razorPay?.toJson();
  data['payPal'] = entity.payPal?.toJson();
  data['phonePe'] = entity.phonePe?.toJson();
  data['payUMoney'] = entity.payUMoney?.toJson();
  data['cashfree'] = entity.cashfree?.toJson();
  data['smepay'] = entity.smepay?.toJson();
  return data;
}

extension PanelResponsePanelPaymentGatewayExtension on PanelResponsePanelPaymentGateway {
  PanelResponsePanelPaymentGateway copyWith({
    PanelResponsePanelPaymentGatewayRazorPay? razorPay,
    PanelResponsePanelPaymentGatewayPayPal? payPal,
    PanelResponsePanelPaymentGatewayPhonePe? phonePe,
    PanelResponsePanelPaymentGatewayPayUMoney? payUMoney,
    PanelResponsePanelPaymentGatewayCashfree? cashfree,
    PanelResponsePanelPaymentGatewaySmepay? smepay,
  }) {
    return PanelResponsePanelPaymentGateway()
      ..razorPay = razorPay ?? this.razorPay
      ..payPal = payPal ?? this.payPal
      ..phonePe = phonePe ?? this.phonePe
      ..payUMoney = payUMoney ?? this.payUMoney
      ..cashfree = cashfree ?? this.cashfree
      ..smepay = smepay ?? this.smepay;
  }
}

PanelResponsePanelPaymentGatewayRazorPay $PanelResponsePanelPaymentGatewayRazorPayFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelPaymentGatewayRazorPay panelResponsePanelPaymentGatewayRazorPay = PanelResponsePanelPaymentGatewayRazorPay();
  final String? keyId = jsonConvert.convert<String>(json['keyId']);
  if (keyId != null) {
    panelResponsePanelPaymentGatewayRazorPay.keyId = keyId;
  }
  final String? keySecret = jsonConvert.convert<String>(json['keySecret']);
  if (keySecret != null) {
    panelResponsePanelPaymentGatewayRazorPay.keySecret = keySecret;
  }
  final String? webhookSecret = jsonConvert.convert<String>(
      json['webhookSecret']);
  if (webhookSecret != null) {
    panelResponsePanelPaymentGatewayRazorPay.webhookSecret = webhookSecret;
  }
  final int? charge = jsonConvert.convert<int>(json['charge']);
  if (charge != null) {
    panelResponsePanelPaymentGatewayRazorPay.charge = charge;
  }
  final bool? enable = jsonConvert.convert<bool>(json['enable']);
  if (enable != null) {
    panelResponsePanelPaymentGatewayRazorPay.enable = enable;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    panelResponsePanelPaymentGatewayRazorPay.updatedAt = updatedAt;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    panelResponsePanelPaymentGatewayRazorPay.id = id;
  }
  return panelResponsePanelPaymentGatewayRazorPay;
}

Map<String, dynamic> $PanelResponsePanelPaymentGatewayRazorPayToJson(
    PanelResponsePanelPaymentGatewayRazorPay entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['keyId'] = entity.keyId;
  data['keySecret'] = entity.keySecret;
  data['webhookSecret'] = entity.webhookSecret;
  data['charge'] = entity.charge;
  data['enable'] = entity.enable;
  data['updatedAt'] = entity.updatedAt;
  data['_id'] = entity.id;
  return data;
}

extension PanelResponsePanelPaymentGatewayRazorPayExtension on PanelResponsePanelPaymentGatewayRazorPay {
  PanelResponsePanelPaymentGatewayRazorPay copyWith({
    String? keyId,
    String? keySecret,
    String? webhookSecret,
    int? charge,
    bool? enable,
    String? updatedAt,
    String? id,
  }) {
    return PanelResponsePanelPaymentGatewayRazorPay()
      ..keyId = keyId ?? this.keyId
      ..keySecret = keySecret ?? this.keySecret
      ..webhookSecret = webhookSecret ?? this.webhookSecret
      ..charge = charge ?? this.charge
      ..enable = enable ?? this.enable
      ..updatedAt = updatedAt ?? this.updatedAt
      ..id = id ?? this.id;
  }
}

PanelResponsePanelPaymentGatewayPayPal $PanelResponsePanelPaymentGatewayPayPalFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelPaymentGatewayPayPal panelResponsePanelPaymentGatewayPayPal = PanelResponsePanelPaymentGatewayPayPal();
  final String? email = jsonConvert.convert<String>(json['email']);
  if (email != null) {
    panelResponsePanelPaymentGatewayPayPal.email = email;
  }
  final String? clientId = jsonConvert.convert<String>(json['clientId']);
  if (clientId != null) {
    panelResponsePanelPaymentGatewayPayPal.clientId = clientId;
  }
  final String? secretKey = jsonConvert.convert<String>(json['secretKey']);
  if (secretKey != null) {
    panelResponsePanelPaymentGatewayPayPal.secretKey = secretKey;
  }
  final int? charge = jsonConvert.convert<int>(json['charge']);
  if (charge != null) {
    panelResponsePanelPaymentGatewayPayPal.charge = charge;
  }
  final bool? enable = jsonConvert.convert<bool>(json['enable']);
  if (enable != null) {
    panelResponsePanelPaymentGatewayPayPal.enable = enable;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    panelResponsePanelPaymentGatewayPayPal.updatedAt = updatedAt;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    panelResponsePanelPaymentGatewayPayPal.id = id;
  }
  return panelResponsePanelPaymentGatewayPayPal;
}

Map<String, dynamic> $PanelResponsePanelPaymentGatewayPayPalToJson(
    PanelResponsePanelPaymentGatewayPayPal entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['email'] = entity.email;
  data['clientId'] = entity.clientId;
  data['secretKey'] = entity.secretKey;
  data['charge'] = entity.charge;
  data['enable'] = entity.enable;
  data['updatedAt'] = entity.updatedAt;
  data['_id'] = entity.id;
  return data;
}

extension PanelResponsePanelPaymentGatewayPayPalExtension on PanelResponsePanelPaymentGatewayPayPal {
  PanelResponsePanelPaymentGatewayPayPal copyWith({
    String? email,
    String? clientId,
    String? secretKey,
    int? charge,
    bool? enable,
    String? updatedAt,
    String? id,
  }) {
    return PanelResponsePanelPaymentGatewayPayPal()
      ..email = email ?? this.email
      ..clientId = clientId ?? this.clientId
      ..secretKey = secretKey ?? this.secretKey
      ..charge = charge ?? this.charge
      ..enable = enable ?? this.enable
      ..updatedAt = updatedAt ?? this.updatedAt
      ..id = id ?? this.id;
  }
}

PanelResponsePanelPaymentGatewayPhonePe $PanelResponsePanelPaymentGatewayPhonePeFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelPaymentGatewayPhonePe panelResponsePanelPaymentGatewayPhonePe = PanelResponsePanelPaymentGatewayPhonePe();
  final String? merchantId = jsonConvert.convert<String>(json['merchantId']);
  if (merchantId != null) {
    panelResponsePanelPaymentGatewayPhonePe.merchantId = merchantId;
  }
  final String? saltKey = jsonConvert.convert<String>(json['saltKey']);
  if (saltKey != null) {
    panelResponsePanelPaymentGatewayPhonePe.saltKey = saltKey;
  }
  final int? charge = jsonConvert.convert<int>(json['charge']);
  if (charge != null) {
    panelResponsePanelPaymentGatewayPhonePe.charge = charge;
  }
  final bool? enable = jsonConvert.convert<bool>(json['enable']);
  if (enable != null) {
    panelResponsePanelPaymentGatewayPhonePe.enable = enable;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    panelResponsePanelPaymentGatewayPhonePe.id = id;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    panelResponsePanelPaymentGatewayPhonePe.updatedAt = updatedAt;
  }
  return panelResponsePanelPaymentGatewayPhonePe;
}

Map<String, dynamic> $PanelResponsePanelPaymentGatewayPhonePeToJson(
    PanelResponsePanelPaymentGatewayPhonePe entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['merchantId'] = entity.merchantId;
  data['saltKey'] = entity.saltKey;
  data['charge'] = entity.charge;
  data['enable'] = entity.enable;
  data['_id'] = entity.id;
  data['updatedAt'] = entity.updatedAt;
  return data;
}

extension PanelResponsePanelPaymentGatewayPhonePeExtension on PanelResponsePanelPaymentGatewayPhonePe {
  PanelResponsePanelPaymentGatewayPhonePe copyWith({
    String? merchantId,
    String? saltKey,
    int? charge,
    bool? enable,
    String? id,
    String? updatedAt,
  }) {
    return PanelResponsePanelPaymentGatewayPhonePe()
      ..merchantId = merchantId ?? this.merchantId
      ..saltKey = saltKey ?? this.saltKey
      ..charge = charge ?? this.charge
      ..enable = enable ?? this.enable
      ..id = id ?? this.id
      ..updatedAt = updatedAt ?? this.updatedAt;
  }
}

PanelResponsePanelPaymentGatewayPayUMoney $PanelResponsePanelPaymentGatewayPayUMoneyFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelPaymentGatewayPayUMoney panelResponsePanelPaymentGatewayPayUMoney = PanelResponsePanelPaymentGatewayPayUMoney();
  final String? merchantKey = jsonConvert.convert<String>(json['merchantKey']);
  if (merchantKey != null) {
    panelResponsePanelPaymentGatewayPayUMoney.merchantKey = merchantKey;
  }
  final String? merchantSalt = jsonConvert.convert<String>(
      json['merchantSalt']);
  if (merchantSalt != null) {
    panelResponsePanelPaymentGatewayPayUMoney.merchantSalt = merchantSalt;
  }
  final int? charge = jsonConvert.convert<int>(json['charge']);
  if (charge != null) {
    panelResponsePanelPaymentGatewayPayUMoney.charge = charge;
  }
  final bool? enable = jsonConvert.convert<bool>(json['enable']);
  if (enable != null) {
    panelResponsePanelPaymentGatewayPayUMoney.enable = enable;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    panelResponsePanelPaymentGatewayPayUMoney.id = id;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    panelResponsePanelPaymentGatewayPayUMoney.updatedAt = updatedAt;
  }
  return panelResponsePanelPaymentGatewayPayUMoney;
}

Map<String, dynamic> $PanelResponsePanelPaymentGatewayPayUMoneyToJson(
    PanelResponsePanelPaymentGatewayPayUMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['merchantKey'] = entity.merchantKey;
  data['merchantSalt'] = entity.merchantSalt;
  data['charge'] = entity.charge;
  data['enable'] = entity.enable;
  data['_id'] = entity.id;
  data['updatedAt'] = entity.updatedAt;
  return data;
}

extension PanelResponsePanelPaymentGatewayPayUMoneyExtension on PanelResponsePanelPaymentGatewayPayUMoney {
  PanelResponsePanelPaymentGatewayPayUMoney copyWith({
    String? merchantKey,
    String? merchantSalt,
    int? charge,
    bool? enable,
    String? id,
    String? updatedAt,
  }) {
    return PanelResponsePanelPaymentGatewayPayUMoney()
      ..merchantKey = merchantKey ?? this.merchantKey
      ..merchantSalt = merchantSalt ?? this.merchantSalt
      ..charge = charge ?? this.charge
      ..enable = enable ?? this.enable
      ..id = id ?? this.id
      ..updatedAt = updatedAt ?? this.updatedAt;
  }
}

PanelResponsePanelPaymentGatewayCashfree $PanelResponsePanelPaymentGatewayCashfreeFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelPaymentGatewayCashfree panelResponsePanelPaymentGatewayCashfree = PanelResponsePanelPaymentGatewayCashfree();
  final String? appId = jsonConvert.convert<String>(json['appId']);
  if (appId != null) {
    panelResponsePanelPaymentGatewayCashfree.appId = appId;
  }
  final String? secretKey = jsonConvert.convert<String>(json['secretKey']);
  if (secretKey != null) {
    panelResponsePanelPaymentGatewayCashfree.secretKey = secretKey;
  }
  final String? env = jsonConvert.convert<String>(json['env']);
  if (env != null) {
    panelResponsePanelPaymentGatewayCashfree.env = env;
  }
  final int? charge = jsonConvert.convert<int>(json['charge']);
  if (charge != null) {
    panelResponsePanelPaymentGatewayCashfree.charge = charge;
  }
  final String? apiVersion = jsonConvert.convert<String>(json['apiVersion']);
  if (apiVersion != null) {
    panelResponsePanelPaymentGatewayCashfree.apiVersion = apiVersion;
  }
  final bool? enable = jsonConvert.convert<bool>(json['enable']);
  if (enable != null) {
    panelResponsePanelPaymentGatewayCashfree.enable = enable;
  }
  final String? webhookSignature = jsonConvert.convert<String>(
      json['webhookSignature']);
  if (webhookSignature != null) {
    panelResponsePanelPaymentGatewayCashfree.webhookSignature =
        webhookSignature;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    panelResponsePanelPaymentGatewayCashfree.id = id;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    panelResponsePanelPaymentGatewayCashfree.updatedAt = updatedAt;
  }
  return panelResponsePanelPaymentGatewayCashfree;
}

Map<String, dynamic> $PanelResponsePanelPaymentGatewayCashfreeToJson(
    PanelResponsePanelPaymentGatewayCashfree entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['appId'] = entity.appId;
  data['secretKey'] = entity.secretKey;
  data['env'] = entity.env;
  data['charge'] = entity.charge;
  data['apiVersion'] = entity.apiVersion;
  data['enable'] = entity.enable;
  data['webhookSignature'] = entity.webhookSignature;
  data['_id'] = entity.id;
  data['updatedAt'] = entity.updatedAt;
  return data;
}

extension PanelResponsePanelPaymentGatewayCashfreeExtension on PanelResponsePanelPaymentGatewayCashfree {
  PanelResponsePanelPaymentGatewayCashfree copyWith({
    String? appId,
    String? secretKey,
    String? env,
    int? charge,
    String? apiVersion,
    bool? enable,
    String? webhookSignature,
    String? id,
    String? updatedAt,
  }) {
    return PanelResponsePanelPaymentGatewayCashfree()
      ..appId = appId ?? this.appId
      ..secretKey = secretKey ?? this.secretKey
      ..env = env ?? this.env
      ..charge = charge ?? this.charge
      ..apiVersion = apiVersion ?? this.apiVersion
      ..enable = enable ?? this.enable
      ..webhookSignature = webhookSignature ?? this.webhookSignature
      ..id = id ?? this.id
      ..updatedAt = updatedAt ?? this.updatedAt;
  }
}

PanelResponsePanelPaymentGatewaySmepay $PanelResponsePanelPaymentGatewaySmepayFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelPaymentGatewaySmepay panelResponsePanelPaymentGatewaySmepay = PanelResponsePanelPaymentGatewaySmepay();
  final String? clientId = jsonConvert.convert<String>(json['client_id']);
  if (clientId != null) {
    panelResponsePanelPaymentGatewaySmepay.clientId = clientId;
  }
  final String? clientSecret = jsonConvert.convert<String>(
      json['client_secret']);
  if (clientSecret != null) {
    panelResponsePanelPaymentGatewaySmepay.clientSecret = clientSecret;
  }
  final int? charge = jsonConvert.convert<int>(json['charge']);
  if (charge != null) {
    panelResponsePanelPaymentGatewaySmepay.charge = charge;
  }
  final bool? enable = jsonConvert.convert<bool>(json['enable']);
  if (enable != null) {
    panelResponsePanelPaymentGatewaySmepay.enable = enable;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    panelResponsePanelPaymentGatewaySmepay.updatedAt = updatedAt;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    panelResponsePanelPaymentGatewaySmepay.id = id;
  }
  return panelResponsePanelPaymentGatewaySmepay;
}

Map<String, dynamic> $PanelResponsePanelPaymentGatewaySmepayToJson(
    PanelResponsePanelPaymentGatewaySmepay entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['client_id'] = entity.clientId;
  data['client_secret'] = entity.clientSecret;
  data['charge'] = entity.charge;
  data['enable'] = entity.enable;
  data['updatedAt'] = entity.updatedAt;
  data['_id'] = entity.id;
  return data;
}

extension PanelResponsePanelPaymentGatewaySmepayExtension on PanelResponsePanelPaymentGatewaySmepay {
  PanelResponsePanelPaymentGatewaySmepay copyWith({
    String? clientId,
    String? clientSecret,
    int? charge,
    bool? enable,
    String? updatedAt,
    String? id,
  }) {
    return PanelResponsePanelPaymentGatewaySmepay()
      ..clientId = clientId ?? this.clientId
      ..clientSecret = clientSecret ?? this.clientSecret
      ..charge = charge ?? this.charge
      ..enable = enable ?? this.enable
      ..updatedAt = updatedAt ?? this.updatedAt
      ..id = id ?? this.id;
  }
}

PanelResponsePanelSeo $PanelResponsePanelSeoFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelSeo panelResponsePanelSeo = PanelResponsePanelSeo();
  final String? title = jsonConvert.convert<String>(json['title']);
  if (title != null) {
    panelResponsePanelSeo.title = title;
  }
  final String? description = jsonConvert.convert<String>(json['description']);
  if (description != null) {
    panelResponsePanelSeo.description = description;
  }
  final String? keywords = jsonConvert.convert<String>(json['keywords']);
  if (keywords != null) {
    panelResponsePanelSeo.keywords = keywords;
  }
  final String? image = jsonConvert.convert<String>(json['image']);
  if (image != null) {
    panelResponsePanelSeo.image = image;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    panelResponsePanelSeo.updatedAt = updatedAt;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    panelResponsePanelSeo.id = id;
  }
  return panelResponsePanelSeo;
}

Map<String, dynamic> $PanelResponsePanelSeoToJson(
    PanelResponsePanelSeo entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['title'] = entity.title;
  data['description'] = entity.description;
  data['keywords'] = entity.keywords;
  data['image'] = entity.image;
  data['updatedAt'] = entity.updatedAt;
  data['_id'] = entity.id;
  return data;
}

extension PanelResponsePanelSeoExtension on PanelResponsePanelSeo {
  PanelResponsePanelSeo copyWith({
    String? title,
    String? description,
    String? keywords,
    String? image,
    String? updatedAt,
    String? id,
  }) {
    return PanelResponsePanelSeo()
      ..title = title ?? this.title
      ..description = description ?? this.description
      ..keywords = keywords ?? this.keywords
      ..image = image ?? this.image
      ..updatedAt = updatedAt ?? this.updatedAt
      ..id = id ?? this.id;
  }
}

PanelResponsePanelBilling $PanelResponsePanelBillingFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelBilling panelResponsePanelBilling = PanelResponsePanelBilling();
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    panelResponsePanelBilling.name = name;
  }
  final String? email = jsonConvert.convert<String>(json['email']);
  if (email != null) {
    panelResponsePanelBilling.email = email;
  }
  final String? phone = jsonConvert.convert<String>(json['phone']);
  if (phone != null) {
    panelResponsePanelBilling.phone = phone;
  }
  final String? gstNumber = jsonConvert.convert<String>(json['gstNumber']);
  if (gstNumber != null) {
    panelResponsePanelBilling.gstNumber = gstNumber;
  }
  final String? address = jsonConvert.convert<String>(json['address']);
  if (address != null) {
    panelResponsePanelBilling.address = address;
  }
  final String? logo = jsonConvert.convert<String>(json['logo']);
  if (logo != null) {
    panelResponsePanelBilling.logo = logo;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    panelResponsePanelBilling.updatedAt = updatedAt;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    panelResponsePanelBilling.id = id;
  }
  return panelResponsePanelBilling;
}

Map<String, dynamic> $PanelResponsePanelBillingToJson(
    PanelResponsePanelBilling entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['name'] = entity.name;
  data['email'] = entity.email;
  data['phone'] = entity.phone;
  data['gstNumber'] = entity.gstNumber;
  data['address'] = entity.address;
  data['logo'] = entity.logo;
  data['updatedAt'] = entity.updatedAt;
  data['_id'] = entity.id;
  return data;
}

extension PanelResponsePanelBillingExtension on PanelResponsePanelBilling {
  PanelResponsePanelBilling copyWith({
    String? name,
    String? email,
    String? phone,
    String? gstNumber,
    String? address,
    String? logo,
    String? updatedAt,
    String? id,
  }) {
    return PanelResponsePanelBilling()
      ..name = name ?? this.name
      ..email = email ?? this.email
      ..phone = phone ?? this.phone
      ..gstNumber = gstNumber ?? this.gstNumber
      ..address = address ?? this.address
      ..logo = logo ?? this.logo
      ..updatedAt = updatedAt ?? this.updatedAt
      ..id = id ?? this.id;
  }
}

PanelResponsePanelGoogleTag $PanelResponsePanelGoogleTagFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelGoogleTag panelResponsePanelGoogleTag = PanelResponsePanelGoogleTag();
  final String? tagManagerId = jsonConvert.convert<String>(
      json['tagManagerId']);
  if (tagManagerId != null) {
    panelResponsePanelGoogleTag.tagManagerId = tagManagerId;
  }
  final String? merchantId = jsonConvert.convert<String>(json['merchantId']);
  if (merchantId != null) {
    panelResponsePanelGoogleTag.merchantId = merchantId;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    panelResponsePanelGoogleTag.updatedAt = updatedAt;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    panelResponsePanelGoogleTag.id = id;
  }
  return panelResponsePanelGoogleTag;
}

Map<String, dynamic> $PanelResponsePanelGoogleTagToJson(
    PanelResponsePanelGoogleTag entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['tagManagerId'] = entity.tagManagerId;
  data['merchantId'] = entity.merchantId;
  data['updatedAt'] = entity.updatedAt;
  data['_id'] = entity.id;
  return data;
}

extension PanelResponsePanelGoogleTagExtension on PanelResponsePanelGoogleTag {
  PanelResponsePanelGoogleTag copyWith({
    String? tagManagerId,
    String? merchantId,
    String? updatedAt,
    String? id,
  }) {
    return PanelResponsePanelGoogleTag()
      ..tagManagerId = tagManagerId ?? this.tagManagerId
      ..merchantId = merchantId ?? this.merchantId
      ..updatedAt = updatedAt ?? this.updatedAt
      ..id = id ?? this.id;
  }
}

PanelResponsePanelPolicy $PanelResponsePanelPolicyFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelPolicy panelResponsePanelPolicy = PanelResponsePanelPolicy();
  final String? termsAndConditions = jsonConvert.convert<String>(
      json['termsAndConditions']);
  if (termsAndConditions != null) {
    panelResponsePanelPolicy.termsAndConditions = termsAndConditions;
  }
  final String? privacyPolicy = jsonConvert.convert<String>(
      json['privacyPolicy']);
  if (privacyPolicy != null) {
    panelResponsePanelPolicy.privacyPolicy = privacyPolicy;
  }
  final String? refundPolicy = jsonConvert.convert<String>(
      json['refundPolicy']);
  if (refundPolicy != null) {
    panelResponsePanelPolicy.refundPolicy = refundPolicy;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    panelResponsePanelPolicy.id = id;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    panelResponsePanelPolicy.updatedAt = updatedAt;
  }
  return panelResponsePanelPolicy;
}

Map<String, dynamic> $PanelResponsePanelPolicyToJson(
    PanelResponsePanelPolicy entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['termsAndConditions'] = entity.termsAndConditions;
  data['privacyPolicy'] = entity.privacyPolicy;
  data['refundPolicy'] = entity.refundPolicy;
  data['_id'] = entity.id;
  data['updatedAt'] = entity.updatedAt;
  return data;
}

extension PanelResponsePanelPolicyExtension on PanelResponsePanelPolicy {
  PanelResponsePanelPolicy copyWith({
    String? termsAndConditions,
    String? privacyPolicy,
    String? refundPolicy,
    String? id,
    String? updatedAt,
  }) {
    return PanelResponsePanelPolicy()
      ..termsAndConditions = termsAndConditions ?? this.termsAndConditions
      ..privacyPolicy = privacyPolicy ?? this.privacyPolicy
      ..refundPolicy = refundPolicy ?? this.refundPolicy
      ..id = id ?? this.id
      ..updatedAt = updatedAt ?? this.updatedAt;
  }
}

PanelResponsePanelCurrencies $PanelResponsePanelCurrenciesFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelCurrencies panelResponsePanelCurrencies = PanelResponsePanelCurrencies();
  final int? position = jsonConvert.convert<int>(json['position']);
  if (position != null) {
    panelResponsePanelCurrencies.position = position;
  }
  final bool? enable = jsonConvert.convert<bool>(json['enable']);
  if (enable != null) {
    panelResponsePanelCurrencies.enable = enable;
  }
  final String? code = jsonConvert.convert<String>(json['code']);
  if (code != null) {
    panelResponsePanelCurrencies.code = code;
  }
  final List<String>? countries = (json['countries'] as List<dynamic>?)?.map(
          (e) => jsonConvert.convert<String>(e) as String).toList();
  if (countries != null) {
    panelResponsePanelCurrencies.countries = countries;
  }
  final List<String>? paymentGateways = (json['paymentGateways'] as List<
      dynamic>?)?.map(
          (e) => jsonConvert.convert<String>(e) as String).toList();
  if (paymentGateways != null) {
    panelResponsePanelCurrencies.paymentGateways = paymentGateways;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    panelResponsePanelCurrencies.id = id;
  }
  return panelResponsePanelCurrencies;
}

Map<String, dynamic> $PanelResponsePanelCurrenciesToJson(
    PanelResponsePanelCurrencies entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['position'] = entity.position;
  data['enable'] = entity.enable;
  data['code'] = entity.code;
  data['countries'] = entity.countries;
  data['paymentGateways'] = entity.paymentGateways;
  data['_id'] = entity.id;
  return data;
}

extension PanelResponsePanelCurrenciesExtension on PanelResponsePanelCurrencies {
  PanelResponsePanelCurrencies copyWith({
    int? position,
    bool? enable,
    String? code,
    List<String>? countries,
    List<String>? paymentGateways,
    String? id,
  }) {
    return PanelResponsePanelCurrencies()
      ..position = position ?? this.position
      ..enable = enable ?? this.enable
      ..code = code ?? this.code
      ..countries = countries ?? this.countries
      ..paymentGateways = paymentGateways ?? this.paymentGateways
      ..id = id ?? this.id;
  }
}

PanelResponsePanelGithub $PanelResponsePanelGithubFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelGithub panelResponsePanelGithub = PanelResponsePanelGithub();
  final String? username = jsonConvert.convert<String>(json['username']);
  if (username != null) {
    panelResponsePanelGithub.username = username;
  }
  final String? token = jsonConvert.convert<String>(json['token']);
  if (token != null) {
    panelResponsePanelGithub.token = token;
  }
  final bool? enable = jsonConvert.convert<bool>(json['enable']);
  if (enable != null) {
    panelResponsePanelGithub.enable = enable;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    panelResponsePanelGithub.updatedAt = updatedAt;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    panelResponsePanelGithub.id = id;
  }
  return panelResponsePanelGithub;
}

Map<String, dynamic> $PanelResponsePanelGithubToJson(
    PanelResponsePanelGithub entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['username'] = entity.username;
  data['token'] = entity.token;
  data['enable'] = entity.enable;
  data['updatedAt'] = entity.updatedAt;
  data['_id'] = entity.id;
  return data;
}

extension PanelResponsePanelGithubExtension on PanelResponsePanelGithub {
  PanelResponsePanelGithub copyWith({
    String? username,
    String? token,
    bool? enable,
    String? updatedAt,
    String? id,
  }) {
    return PanelResponsePanelGithub()
      ..username = username ?? this.username
      ..token = token ?? this.token
      ..enable = enable ?? this.enable
      ..updatedAt = updatedAt ?? this.updatedAt
      ..id = id ?? this.id;
  }
}

PanelResponsePanelCrm $PanelResponsePanelCrmFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelCrm panelResponsePanelCrm = PanelResponsePanelCrm();
  final PanelResponsePanelCrmSupport? support = jsonConvert.convert<
      PanelResponsePanelCrmSupport>(json['support']);
  if (support != null) {
    panelResponsePanelCrm.support = support;
  }
  final bool? enable = jsonConvert.convert<bool>(json['enable']);
  if (enable != null) {
    panelResponsePanelCrm.enable = enable;
  }
  final String? domain = jsonConvert.convert<String>(json['domain']);
  if (domain != null) {
    panelResponsePanelCrm.domain = domain;
  }
  final bool? dns = jsonConvert.convert<bool>(json['dns']);
  if (dns != null) {
    panelResponsePanelCrm.dns = dns;
  }
  final bool? ssl = jsonConvert.convert<bool>(json['ssl']);
  if (ssl != null) {
    panelResponsePanelCrm.ssl = ssl;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    panelResponsePanelCrm.name = name;
  }
  final String? description = jsonConvert.convert<String>(json['description']);
  if (description != null) {
    panelResponsePanelCrm.description = description;
  }
  final String? slogan = jsonConvert.convert<String>(json['slogan']);
  if (slogan != null) {
    panelResponsePanelCrm.slogan = slogan;
  }
  final String? favicon = jsonConvert.convert<String>(json['favicon']);
  if (favicon != null) {
    panelResponsePanelCrm.favicon = favicon;
  }
  final String? logo = jsonConvert.convert<String>(json['logo']);
  if (logo != null) {
    panelResponsePanelCrm.logo = logo;
  }
  final String? logoLong = jsonConvert.convert<String>(json['logoLong']);
  if (logoLong != null) {
    panelResponsePanelCrm.logoLong = logoLong;
  }
  final String? phone = jsonConvert.convert<String>(json['phone']);
  if (phone != null) {
    panelResponsePanelCrm.phone = phone;
  }
  final String? email = jsonConvert.convert<String>(json['email']);
  if (email != null) {
    panelResponsePanelCrm.email = email;
  }
  final String? address = jsonConvert.convert<String>(json['address']);
  if (address != null) {
    panelResponsePanelCrm.address = address;
  }
  final String? country = jsonConvert.convert<String>(json['country']);
  if (country != null) {
    panelResponsePanelCrm.country = country;
  }
  final String? dialCode = jsonConvert.convert<String>(json['dialCode']);
  if (dialCode != null) {
    panelResponsePanelCrm.dialCode = dialCode;
  }
  final String? language = jsonConvert.convert<String>(json['language']);
  if (language != null) {
    panelResponsePanelCrm.language = language;
  }
  final PanelResponsePanelCrmSocialMedia? socialMedia = jsonConvert.convert<
      PanelResponsePanelCrmSocialMedia>(json['socialMedia']);
  if (socialMedia != null) {
    panelResponsePanelCrm.socialMedia = socialMedia;
  }
  final PanelResponsePanelCrmTheme? theme = jsonConvert.convert<
      PanelResponsePanelCrmTheme>(json['theme']);
  if (theme != null) {
    panelResponsePanelCrm.theme = theme;
  }
  final PanelResponsePanelCrmCarousel? carousel = jsonConvert.convert<
      PanelResponsePanelCrmCarousel>(json['carousel']);
  if (carousel != null) {
    panelResponsePanelCrm.carousel = carousel;
  }
  final PanelResponsePanelCrmRate? rate = jsonConvert.convert<
      PanelResponsePanelCrmRate>(json['rate']);
  if (rate != null) {
    panelResponsePanelCrm.rate = rate;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    panelResponsePanelCrm.updatedAt = updatedAt;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    panelResponsePanelCrm.id = id;
  }
  return panelResponsePanelCrm;
}

Map<String, dynamic> $PanelResponsePanelCrmToJson(
    PanelResponsePanelCrm entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['support'] = entity.support?.toJson();
  data['enable'] = entity.enable;
  data['domain'] = entity.domain;
  data['dns'] = entity.dns;
  data['ssl'] = entity.ssl;
  data['name'] = entity.name;
  data['description'] = entity.description;
  data['slogan'] = entity.slogan;
  data['favicon'] = entity.favicon;
  data['logo'] = entity.logo;
  data['logoLong'] = entity.logoLong;
  data['phone'] = entity.phone;
  data['email'] = entity.email;
  data['address'] = entity.address;
  data['country'] = entity.country;
  data['dialCode'] = entity.dialCode;
  data['language'] = entity.language;
  data['socialMedia'] = entity.socialMedia?.toJson();
  data['theme'] = entity.theme?.toJson();
  data['carousel'] = entity.carousel?.toJson();
  data['rate'] = entity.rate?.toJson();
  data['updatedAt'] = entity.updatedAt;
  data['_id'] = entity.id;
  return data;
}

extension PanelResponsePanelCrmExtension on PanelResponsePanelCrm {
  PanelResponsePanelCrm copyWith({
    PanelResponsePanelCrmSupport? support,
    bool? enable,
    String? domain,
    bool? dns,
    bool? ssl,
    String? name,
    String? description,
    String? slogan,
    String? favicon,
    String? logo,
    String? logoLong,
    String? phone,
    String? email,
    String? address,
    String? country,
    String? dialCode,
    String? language,
    PanelResponsePanelCrmSocialMedia? socialMedia,
    PanelResponsePanelCrmTheme? theme,
    PanelResponsePanelCrmCarousel? carousel,
    PanelResponsePanelCrmRate? rate,
    String? updatedAt,
    String? id,
  }) {
    return PanelResponsePanelCrm()
      ..support = support ?? this.support
      ..enable = enable ?? this.enable
      ..domain = domain ?? this.domain
      ..dns = dns ?? this.dns
      ..ssl = ssl ?? this.ssl
      ..name = name ?? this.name
      ..description = description ?? this.description
      ..slogan = slogan ?? this.slogan
      ..favicon = favicon ?? this.favicon
      ..logo = logo ?? this.logo
      ..logoLong = logoLong ?? this.logoLong
      ..phone = phone ?? this.phone
      ..email = email ?? this.email
      ..address = address ?? this.address
      ..country = country ?? this.country
      ..dialCode = dialCode ?? this.dialCode
      ..language = language ?? this.language
      ..socialMedia = socialMedia ?? this.socialMedia
      ..theme = theme ?? this.theme
      ..carousel = carousel ?? this.carousel
      ..rate = rate ?? this.rate
      ..updatedAt = updatedAt ?? this.updatedAt
      ..id = id ?? this.id;
  }
}

PanelResponsePanelCrmSupport $PanelResponsePanelCrmSupportFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelCrmSupport panelResponsePanelCrmSupport = PanelResponsePanelCrmSupport();
  final List<dynamic>? whatsApp = (json['whatsApp'] as List<dynamic>?)?.map(
          (e) => e).toList();
  if (whatsApp != null) {
    panelResponsePanelCrmSupport.whatsApp = whatsApp;
  }
  return panelResponsePanelCrmSupport;
}

Map<String, dynamic> $PanelResponsePanelCrmSupportToJson(
    PanelResponsePanelCrmSupport entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['whatsApp'] = entity.whatsApp;
  return data;
}

extension PanelResponsePanelCrmSupportExtension on PanelResponsePanelCrmSupport {
  PanelResponsePanelCrmSupport copyWith({
    List<dynamic>? whatsApp,
  }) {
    return PanelResponsePanelCrmSupport()
      ..whatsApp = whatsApp ?? this.whatsApp;
  }
}

PanelResponsePanelCrmSocialMedia $PanelResponsePanelCrmSocialMediaFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelCrmSocialMedia panelResponsePanelCrmSocialMedia = PanelResponsePanelCrmSocialMedia();
  final String? facebook = jsonConvert.convert<String>(json['facebook']);
  if (facebook != null) {
    panelResponsePanelCrmSocialMedia.facebook = facebook;
  }
  final String? instagram = jsonConvert.convert<String>(json['instagram']);
  if (instagram != null) {
    panelResponsePanelCrmSocialMedia.instagram = instagram;
  }
  final String? twitter = jsonConvert.convert<String>(json['twitter']);
  if (twitter != null) {
    panelResponsePanelCrmSocialMedia.twitter = twitter;
  }
  final String? linkedin = jsonConvert.convert<String>(json['linkedin']);
  if (linkedin != null) {
    panelResponsePanelCrmSocialMedia.linkedin = linkedin;
  }
  final String? youtube = jsonConvert.convert<String>(json['youtube']);
  if (youtube != null) {
    panelResponsePanelCrmSocialMedia.youtube = youtube;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    panelResponsePanelCrmSocialMedia.updatedAt = updatedAt;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    panelResponsePanelCrmSocialMedia.id = id;
  }
  return panelResponsePanelCrmSocialMedia;
}

Map<String, dynamic> $PanelResponsePanelCrmSocialMediaToJson(
    PanelResponsePanelCrmSocialMedia entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['facebook'] = entity.facebook;
  data['instagram'] = entity.instagram;
  data['twitter'] = entity.twitter;
  data['linkedin'] = entity.linkedin;
  data['youtube'] = entity.youtube;
  data['updatedAt'] = entity.updatedAt;
  data['_id'] = entity.id;
  return data;
}

extension PanelResponsePanelCrmSocialMediaExtension on PanelResponsePanelCrmSocialMedia {
  PanelResponsePanelCrmSocialMedia copyWith({
    String? facebook,
    String? instagram,
    String? twitter,
    String? linkedin,
    String? youtube,
    String? updatedAt,
    String? id,
  }) {
    return PanelResponsePanelCrmSocialMedia()
      ..facebook = facebook ?? this.facebook
      ..instagram = instagram ?? this.instagram
      ..twitter = twitter ?? this.twitter
      ..linkedin = linkedin ?? this.linkedin
      ..youtube = youtube ?? this.youtube
      ..updatedAt = updatedAt ?? this.updatedAt
      ..id = id ?? this.id;
  }
}

PanelResponsePanelCrmTheme $PanelResponsePanelCrmThemeFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelCrmTheme panelResponsePanelCrmTheme = PanelResponsePanelCrmTheme();
  final PanelResponsePanelCrmThemeToken? token = jsonConvert.convert<
      PanelResponsePanelCrmThemeToken>(json['token']);
  if (token != null) {
    panelResponsePanelCrmTheme.token = token;
  }
  final String? algorithm = jsonConvert.convert<String>(json['algorithm']);
  if (algorithm != null) {
    panelResponsePanelCrmTheme.algorithm = algorithm;
  }
  return panelResponsePanelCrmTheme;
}

Map<String, dynamic> $PanelResponsePanelCrmThemeToJson(
    PanelResponsePanelCrmTheme entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['token'] = entity.token?.toJson();
  data['algorithm'] = entity.algorithm;
  return data;
}

extension PanelResponsePanelCrmThemeExtension on PanelResponsePanelCrmTheme {
  PanelResponsePanelCrmTheme copyWith({
    PanelResponsePanelCrmThemeToken? token,
    String? algorithm,
  }) {
    return PanelResponsePanelCrmTheme()
      ..token = token ?? this.token
      ..algorithm = algorithm ?? this.algorithm;
  }
}

PanelResponsePanelCrmThemeToken $PanelResponsePanelCrmThemeTokenFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelCrmThemeToken panelResponsePanelCrmThemeToken = PanelResponsePanelCrmThemeToken();
  final String? colorPrimary = jsonConvert.convert<String>(
      json['colorPrimary']);
  if (colorPrimary != null) {
    panelResponsePanelCrmThemeToken.colorPrimary = colorPrimary;
  }
  final int? borderRadius = jsonConvert.convert<int>(json['borderRadius']);
  if (borderRadius != null) {
    panelResponsePanelCrmThemeToken.borderRadius = borderRadius;
  }
  return panelResponsePanelCrmThemeToken;
}

Map<String, dynamic> $PanelResponsePanelCrmThemeTokenToJson(
    PanelResponsePanelCrmThemeToken entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['colorPrimary'] = entity.colorPrimary;
  data['borderRadius'] = entity.borderRadius;
  return data;
}

extension PanelResponsePanelCrmThemeTokenExtension on PanelResponsePanelCrmThemeToken {
  PanelResponsePanelCrmThemeToken copyWith({
    String? colorPrimary,
    int? borderRadius,
  }) {
    return PanelResponsePanelCrmThemeToken()
      ..colorPrimary = colorPrimary ?? this.colorPrimary
      ..borderRadius = borderRadius ?? this.borderRadius;
  }
}

PanelResponsePanelCrmCarousel $PanelResponsePanelCrmCarouselFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelCrmCarousel panelResponsePanelCrmCarousel = PanelResponsePanelCrmCarousel();
  final bool? enable = jsonConvert.convert<bool>(json['enable']);
  if (enable != null) {
    panelResponsePanelCrmCarousel.enable = enable;
  }
  final String? image = jsonConvert.convert<String>(json['image']);
  if (image != null) {
    panelResponsePanelCrmCarousel.image = image;
  }
  final String? link = jsonConvert.convert<String>(json['link']);
  if (link != null) {
    panelResponsePanelCrmCarousel.link = link;
  }
  final List<dynamic>? items = (json['items'] as List<dynamic>?)?.map(
          (e) => e).toList();
  if (items != null) {
    panelResponsePanelCrmCarousel.items = items;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    panelResponsePanelCrmCarousel.id = id;
  }
  return panelResponsePanelCrmCarousel;
}

Map<String, dynamic> $PanelResponsePanelCrmCarouselToJson(
    PanelResponsePanelCrmCarousel entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['enable'] = entity.enable;
  data['image'] = entity.image;
  data['link'] = entity.link;
  data['items'] = entity.items;
  data['_id'] = entity.id;
  return data;
}

extension PanelResponsePanelCrmCarouselExtension on PanelResponsePanelCrmCarousel {
  PanelResponsePanelCrmCarousel copyWith({
    bool? enable,
    String? image,
    String? link,
    List<dynamic>? items,
    String? id,
  }) {
    return PanelResponsePanelCrmCarousel()
      ..enable = enable ?? this.enable
      ..image = image ?? this.image
      ..link = link ?? this.link
      ..items = items ?? this.items
      ..id = id ?? this.id;
  }
}

PanelResponsePanelCrmRate $PanelResponsePanelCrmRateFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelCrmRate panelResponsePanelCrmRate = PanelResponsePanelCrmRate();
  final PanelResponsePanelCrmRateUser? user = jsonConvert.convert<
      PanelResponsePanelCrmRateUser>(json['user']);
  if (user != null) {
    panelResponsePanelCrmRate.user = user;
  }
  final PanelResponsePanelCrmRateMaster? master = jsonConvert.convert<
      PanelResponsePanelCrmRateMaster>(json['master']);
  if (master != null) {
    panelResponsePanelCrmRate.master = master;
  }
  return panelResponsePanelCrmRate;
}

Map<String, dynamic> $PanelResponsePanelCrmRateToJson(
    PanelResponsePanelCrmRate entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['user'] = entity.user?.toJson();
  data['master'] = entity.master?.toJson();
  return data;
}

extension PanelResponsePanelCrmRateExtension on PanelResponsePanelCrmRate {
  PanelResponsePanelCrmRate copyWith({
    PanelResponsePanelCrmRateUser? user,
    PanelResponsePanelCrmRateMaster? master,
  }) {
    return PanelResponsePanelCrmRate()
      ..user = user ?? this.user
      ..master = master ?? this.master;
  }
}

PanelResponsePanelCrmRateUser $PanelResponsePanelCrmRateUserFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelCrmRateUser panelResponsePanelCrmRateUser = PanelResponsePanelCrmRateUser();
  final List<
      PanelResponsePanelCrmRateUserInstance>? instance = (json['instance'] as List<
      dynamic>?)?.map(
          (e) =>
      jsonConvert.convert<PanelResponsePanelCrmRateUserInstance>(
          e) as PanelResponsePanelCrmRateUserInstance).toList();
  if (instance != null) {
    panelResponsePanelCrmRateUser.instance = instance;
  }
  final List<
      PanelResponsePanelCrmRateUserMember>? member = (json['member'] as List<
      dynamic>?)?.map(
          (e) =>
      jsonConvert.convert<PanelResponsePanelCrmRateUserMember>(
          e) as PanelResponsePanelCrmRateUserMember).toList();
  if (member != null) {
    panelResponsePanelCrmRateUser.member = member;
  }
  final List<
      PanelResponsePanelCrmRateUserEmail>? email = (json['email'] as List<
      dynamic>?)?.map(
          (e) =>
      jsonConvert.convert<PanelResponsePanelCrmRateUserEmail>(
          e) as PanelResponsePanelCrmRateUserEmail).toList();
  if (email != null) {
    panelResponsePanelCrmRateUser.email = email;
  }
  final List<
      PanelResponsePanelCrmRateUserTelecaller>? telecaller = (json['telecaller'] as List<
      dynamic>?)?.map(
          (e) =>
      jsonConvert.convert<PanelResponsePanelCrmRateUserTelecaller>(
          e) as PanelResponsePanelCrmRateUserTelecaller).toList();
  if (telecaller != null) {
    panelResponsePanelCrmRateUser.telecaller = telecaller;
  }
  return panelResponsePanelCrmRateUser;
}

Map<String, dynamic> $PanelResponsePanelCrmRateUserToJson(
    PanelResponsePanelCrmRateUser entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['instance'] = entity.instance?.map((v) => v.toJson()).toList();
  data['member'] = entity.member?.map((v) => v.toJson()).toList();
  data['email'] = entity.email?.map((v) => v.toJson()).toList();
  data['telecaller'] = entity.telecaller?.map((v) => v.toJson()).toList();
  return data;
}

extension PanelResponsePanelCrmRateUserExtension on PanelResponsePanelCrmRateUser {
  PanelResponsePanelCrmRateUser copyWith({
    List<PanelResponsePanelCrmRateUserInstance>? instance,
    List<PanelResponsePanelCrmRateUserMember>? member,
    List<PanelResponsePanelCrmRateUserEmail>? email,
    List<PanelResponsePanelCrmRateUserTelecaller>? telecaller,
  }) {
    return PanelResponsePanelCrmRateUser()
      ..instance = instance ?? this.instance
      ..member = member ?? this.member
      ..email = email ?? this.email
      ..telecaller = telecaller ?? this.telecaller;
  }
}

PanelResponsePanelCrmRateUserInstance $PanelResponsePanelCrmRateUserInstanceFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelCrmRateUserInstance panelResponsePanelCrmRateUserInstance = PanelResponsePanelCrmRateUserInstance();
  final bool? enable = jsonConvert.convert<bool>(json['enable']);
  if (enable != null) {
    panelResponsePanelCrmRateUserInstance.enable = enable;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    panelResponsePanelCrmRateUserInstance.name = name;
  }
  final int? price = jsonConvert.convert<int>(json['price']);
  if (price != null) {
    panelResponsePanelCrmRateUserInstance.price = price;
  }
  final int? valid = jsonConvert.convert<int>(json['valid']);
  if (valid != null) {
    panelResponsePanelCrmRateUserInstance.valid = valid;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    panelResponsePanelCrmRateUserInstance.updatedAt = updatedAt;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    panelResponsePanelCrmRateUserInstance.id = id;
  }
  return panelResponsePanelCrmRateUserInstance;
}

Map<String, dynamic> $PanelResponsePanelCrmRateUserInstanceToJson(
    PanelResponsePanelCrmRateUserInstance entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['enable'] = entity.enable;
  data['name'] = entity.name;
  data['price'] = entity.price;
  data['valid'] = entity.valid;
  data['updatedAt'] = entity.updatedAt;
  data['_id'] = entity.id;
  return data;
}

extension PanelResponsePanelCrmRateUserInstanceExtension on PanelResponsePanelCrmRateUserInstance {
  PanelResponsePanelCrmRateUserInstance copyWith({
    bool? enable,
    String? name,
    int? price,
    int? valid,
    String? updatedAt,
    String? id,
  }) {
    return PanelResponsePanelCrmRateUserInstance()
      ..enable = enable ?? this.enable
      ..name = name ?? this.name
      ..price = price ?? this.price
      ..valid = valid ?? this.valid
      ..updatedAt = updatedAt ?? this.updatedAt
      ..id = id ?? this.id;
  }
}

PanelResponsePanelCrmRateUserMember $PanelResponsePanelCrmRateUserMemberFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelCrmRateUserMember panelResponsePanelCrmRateUserMember = PanelResponsePanelCrmRateUserMember();
  final bool? enable = jsonConvert.convert<bool>(json['enable']);
  if (enable != null) {
    panelResponsePanelCrmRateUserMember.enable = enable;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    panelResponsePanelCrmRateUserMember.name = name;
  }
  final int? price = jsonConvert.convert<int>(json['price']);
  if (price != null) {
    panelResponsePanelCrmRateUserMember.price = price;
  }
  final int? valid = jsonConvert.convert<int>(json['valid']);
  if (valid != null) {
    panelResponsePanelCrmRateUserMember.valid = valid;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    panelResponsePanelCrmRateUserMember.updatedAt = updatedAt;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    panelResponsePanelCrmRateUserMember.id = id;
  }
  return panelResponsePanelCrmRateUserMember;
}

Map<String, dynamic> $PanelResponsePanelCrmRateUserMemberToJson(
    PanelResponsePanelCrmRateUserMember entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['enable'] = entity.enable;
  data['name'] = entity.name;
  data['price'] = entity.price;
  data['valid'] = entity.valid;
  data['updatedAt'] = entity.updatedAt;
  data['_id'] = entity.id;
  return data;
}

extension PanelResponsePanelCrmRateUserMemberExtension on PanelResponsePanelCrmRateUserMember {
  PanelResponsePanelCrmRateUserMember copyWith({
    bool? enable,
    String? name,
    int? price,
    int? valid,
    String? updatedAt,
    String? id,
  }) {
    return PanelResponsePanelCrmRateUserMember()
      ..enable = enable ?? this.enable
      ..name = name ?? this.name
      ..price = price ?? this.price
      ..valid = valid ?? this.valid
      ..updatedAt = updatedAt ?? this.updatedAt
      ..id = id ?? this.id;
  }
}

PanelResponsePanelCrmRateUserEmail $PanelResponsePanelCrmRateUserEmailFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelCrmRateUserEmail panelResponsePanelCrmRateUserEmail = PanelResponsePanelCrmRateUserEmail();
  final bool? enable = jsonConvert.convert<bool>(json['enable']);
  if (enable != null) {
    panelResponsePanelCrmRateUserEmail.enable = enable;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    panelResponsePanelCrmRateUserEmail.name = name;
  }
  final int? price = jsonConvert.convert<int>(json['price']);
  if (price != null) {
    panelResponsePanelCrmRateUserEmail.price = price;
  }
  final int? valid = jsonConvert.convert<int>(json['valid']);
  if (valid != null) {
    panelResponsePanelCrmRateUserEmail.valid = valid;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    panelResponsePanelCrmRateUserEmail.updatedAt = updatedAt;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    panelResponsePanelCrmRateUserEmail.id = id;
  }
  return panelResponsePanelCrmRateUserEmail;
}

Map<String, dynamic> $PanelResponsePanelCrmRateUserEmailToJson(
    PanelResponsePanelCrmRateUserEmail entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['enable'] = entity.enable;
  data['name'] = entity.name;
  data['price'] = entity.price;
  data['valid'] = entity.valid;
  data['updatedAt'] = entity.updatedAt;
  data['_id'] = entity.id;
  return data;
}

extension PanelResponsePanelCrmRateUserEmailExtension on PanelResponsePanelCrmRateUserEmail {
  PanelResponsePanelCrmRateUserEmail copyWith({
    bool? enable,
    String? name,
    int? price,
    int? valid,
    String? updatedAt,
    String? id,
  }) {
    return PanelResponsePanelCrmRateUserEmail()
      ..enable = enable ?? this.enable
      ..name = name ?? this.name
      ..price = price ?? this.price
      ..valid = valid ?? this.valid
      ..updatedAt = updatedAt ?? this.updatedAt
      ..id = id ?? this.id;
  }
}

PanelResponsePanelCrmRateUserTelecaller $PanelResponsePanelCrmRateUserTelecallerFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelCrmRateUserTelecaller panelResponsePanelCrmRateUserTelecaller = PanelResponsePanelCrmRateUserTelecaller();
  final bool? enable = jsonConvert.convert<bool>(json['enable']);
  if (enable != null) {
    panelResponsePanelCrmRateUserTelecaller.enable = enable;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    panelResponsePanelCrmRateUserTelecaller.name = name;
  }
  final int? price = jsonConvert.convert<int>(json['price']);
  if (price != null) {
    panelResponsePanelCrmRateUserTelecaller.price = price;
  }
  final int? valid = jsonConvert.convert<int>(json['valid']);
  if (valid != null) {
    panelResponsePanelCrmRateUserTelecaller.valid = valid;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    panelResponsePanelCrmRateUserTelecaller.updatedAt = updatedAt;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    panelResponsePanelCrmRateUserTelecaller.id = id;
  }
  return panelResponsePanelCrmRateUserTelecaller;
}

Map<String, dynamic> $PanelResponsePanelCrmRateUserTelecallerToJson(
    PanelResponsePanelCrmRateUserTelecaller entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['enable'] = entity.enable;
  data['name'] = entity.name;
  data['price'] = entity.price;
  data['valid'] = entity.valid;
  data['updatedAt'] = entity.updatedAt;
  data['_id'] = entity.id;
  return data;
}

extension PanelResponsePanelCrmRateUserTelecallerExtension on PanelResponsePanelCrmRateUserTelecaller {
  PanelResponsePanelCrmRateUserTelecaller copyWith({
    bool? enable,
    String? name,
    int? price,
    int? valid,
    String? updatedAt,
    String? id,
  }) {
    return PanelResponsePanelCrmRateUserTelecaller()
      ..enable = enable ?? this.enable
      ..name = name ?? this.name
      ..price = price ?? this.price
      ..valid = valid ?? this.valid
      ..updatedAt = updatedAt ?? this.updatedAt
      ..id = id ?? this.id;
  }
}

PanelResponsePanelCrmRateMaster $PanelResponsePanelCrmRateMasterFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelCrmRateMaster panelResponsePanelCrmRateMaster = PanelResponsePanelCrmRateMaster();
  final List<
      PanelResponsePanelCrmRateMasterMember>? member = (json['member'] as List<
      dynamic>?)?.map(
          (e) =>
      jsonConvert.convert<PanelResponsePanelCrmRateMasterMember>(
          e) as PanelResponsePanelCrmRateMasterMember).toList();
  if (member != null) {
    panelResponsePanelCrmRateMaster.member = member;
  }
  final List<
      PanelResponsePanelCrmRateMasterInstance>? instance = (json['instance'] as List<
      dynamic>?)?.map(
          (e) =>
      jsonConvert.convert<PanelResponsePanelCrmRateMasterInstance>(
          e) as PanelResponsePanelCrmRateMasterInstance).toList();
  if (instance != null) {
    panelResponsePanelCrmRateMaster.instance = instance;
  }
  final List<
      PanelResponsePanelCrmRateMasterEmail>? email = (json['email'] as List<
      dynamic>?)?.map(
          (e) =>
      jsonConvert.convert<PanelResponsePanelCrmRateMasterEmail>(
          e) as PanelResponsePanelCrmRateMasterEmail).toList();
  if (email != null) {
    panelResponsePanelCrmRateMaster.email = email;
  }
  final List<
      PanelResponsePanelCrmRateMasterTelecaller>? telecaller = (json['telecaller'] as List<
      dynamic>?)?.map(
          (e) =>
      jsonConvert.convert<PanelResponsePanelCrmRateMasterTelecaller>(
          e) as PanelResponsePanelCrmRateMasterTelecaller).toList();
  if (telecaller != null) {
    panelResponsePanelCrmRateMaster.telecaller = telecaller;
  }
  return panelResponsePanelCrmRateMaster;
}

Map<String, dynamic> $PanelResponsePanelCrmRateMasterToJson(
    PanelResponsePanelCrmRateMaster entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['member'] = entity.member?.map((v) => v.toJson()).toList();
  data['instance'] = entity.instance?.map((v) => v.toJson()).toList();
  data['email'] = entity.email?.map((v) => v.toJson()).toList();
  data['telecaller'] = entity.telecaller?.map((v) => v.toJson()).toList();
  return data;
}

extension PanelResponsePanelCrmRateMasterExtension on PanelResponsePanelCrmRateMaster {
  PanelResponsePanelCrmRateMaster copyWith({
    List<PanelResponsePanelCrmRateMasterMember>? member,
    List<PanelResponsePanelCrmRateMasterInstance>? instance,
    List<PanelResponsePanelCrmRateMasterEmail>? email,
    List<PanelResponsePanelCrmRateMasterTelecaller>? telecaller,
  }) {
    return PanelResponsePanelCrmRateMaster()
      ..member = member ?? this.member
      ..instance = instance ?? this.instance
      ..email = email ?? this.email
      ..telecaller = telecaller ?? this.telecaller;
  }
}

PanelResponsePanelCrmRateMasterMember $PanelResponsePanelCrmRateMasterMemberFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelCrmRateMasterMember panelResponsePanelCrmRateMasterMember = PanelResponsePanelCrmRateMasterMember();
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    panelResponsePanelCrmRateMasterMember.id = id;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    panelResponsePanelCrmRateMasterMember.name = name;
  }
  final int? price = jsonConvert.convert<int>(json['price']);
  if (price != null) {
    panelResponsePanelCrmRateMasterMember.price = price;
  }
  final int? valid = jsonConvert.convert<int>(json['valid']);
  if (valid != null) {
    panelResponsePanelCrmRateMasterMember.valid = valid;
  }
  final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
  if (createdAt != null) {
    panelResponsePanelCrmRateMasterMember.createdAt = createdAt;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    panelResponsePanelCrmRateMasterMember.updatedAt = updatedAt;
  }
  return panelResponsePanelCrmRateMasterMember;
}

Map<String, dynamic> $PanelResponsePanelCrmRateMasterMemberToJson(
    PanelResponsePanelCrmRateMasterMember entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['_id'] = entity.id;
  data['name'] = entity.name;
  data['price'] = entity.price;
  data['valid'] = entity.valid;
  data['createdAt'] = entity.createdAt;
  data['updatedAt'] = entity.updatedAt;
  return data;
}

extension PanelResponsePanelCrmRateMasterMemberExtension on PanelResponsePanelCrmRateMasterMember {
  PanelResponsePanelCrmRateMasterMember copyWith({
    String? id,
    String? name,
    int? price,
    int? valid,
    String? createdAt,
    String? updatedAt,
  }) {
    return PanelResponsePanelCrmRateMasterMember()
      ..id = id ?? this.id
      ..name = name ?? this.name
      ..price = price ?? this.price
      ..valid = valid ?? this.valid
      ..createdAt = createdAt ?? this.createdAt
      ..updatedAt = updatedAt ?? this.updatedAt;
  }
}

PanelResponsePanelCrmRateMasterInstance $PanelResponsePanelCrmRateMasterInstanceFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelCrmRateMasterInstance panelResponsePanelCrmRateMasterInstance = PanelResponsePanelCrmRateMasterInstance();
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    panelResponsePanelCrmRateMasterInstance.id = id;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    panelResponsePanelCrmRateMasterInstance.name = name;
  }
  final int? price = jsonConvert.convert<int>(json['price']);
  if (price != null) {
    panelResponsePanelCrmRateMasterInstance.price = price;
  }
  final int? valid = jsonConvert.convert<int>(json['valid']);
  if (valid != null) {
    panelResponsePanelCrmRateMasterInstance.valid = valid;
  }
  final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
  if (createdAt != null) {
    panelResponsePanelCrmRateMasterInstance.createdAt = createdAt;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    panelResponsePanelCrmRateMasterInstance.updatedAt = updatedAt;
  }
  return panelResponsePanelCrmRateMasterInstance;
}

Map<String, dynamic> $PanelResponsePanelCrmRateMasterInstanceToJson(
    PanelResponsePanelCrmRateMasterInstance entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['_id'] = entity.id;
  data['name'] = entity.name;
  data['price'] = entity.price;
  data['valid'] = entity.valid;
  data['createdAt'] = entity.createdAt;
  data['updatedAt'] = entity.updatedAt;
  return data;
}

extension PanelResponsePanelCrmRateMasterInstanceExtension on PanelResponsePanelCrmRateMasterInstance {
  PanelResponsePanelCrmRateMasterInstance copyWith({
    String? id,
    String? name,
    int? price,
    int? valid,
    String? createdAt,
    String? updatedAt,
  }) {
    return PanelResponsePanelCrmRateMasterInstance()
      ..id = id ?? this.id
      ..name = name ?? this.name
      ..price = price ?? this.price
      ..valid = valid ?? this.valid
      ..createdAt = createdAt ?? this.createdAt
      ..updatedAt = updatedAt ?? this.updatedAt;
  }
}

PanelResponsePanelCrmRateMasterEmail $PanelResponsePanelCrmRateMasterEmailFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelCrmRateMasterEmail panelResponsePanelCrmRateMasterEmail = PanelResponsePanelCrmRateMasterEmail();
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    panelResponsePanelCrmRateMasterEmail.id = id;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    panelResponsePanelCrmRateMasterEmail.name = name;
  }
  final int? price = jsonConvert.convert<int>(json['price']);
  if (price != null) {
    panelResponsePanelCrmRateMasterEmail.price = price;
  }
  final int? valid = jsonConvert.convert<int>(json['valid']);
  if (valid != null) {
    panelResponsePanelCrmRateMasterEmail.valid = valid;
  }
  final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
  if (createdAt != null) {
    panelResponsePanelCrmRateMasterEmail.createdAt = createdAt;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    panelResponsePanelCrmRateMasterEmail.updatedAt = updatedAt;
  }
  return panelResponsePanelCrmRateMasterEmail;
}

Map<String, dynamic> $PanelResponsePanelCrmRateMasterEmailToJson(
    PanelResponsePanelCrmRateMasterEmail entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['_id'] = entity.id;
  data['name'] = entity.name;
  data['price'] = entity.price;
  data['valid'] = entity.valid;
  data['createdAt'] = entity.createdAt;
  data['updatedAt'] = entity.updatedAt;
  return data;
}

extension PanelResponsePanelCrmRateMasterEmailExtension on PanelResponsePanelCrmRateMasterEmail {
  PanelResponsePanelCrmRateMasterEmail copyWith({
    String? id,
    String? name,
    int? price,
    int? valid,
    String? createdAt,
    String? updatedAt,
  }) {
    return PanelResponsePanelCrmRateMasterEmail()
      ..id = id ?? this.id
      ..name = name ?? this.name
      ..price = price ?? this.price
      ..valid = valid ?? this.valid
      ..createdAt = createdAt ?? this.createdAt
      ..updatedAt = updatedAt ?? this.updatedAt;
  }
}

PanelResponsePanelCrmRateMasterTelecaller $PanelResponsePanelCrmRateMasterTelecallerFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelCrmRateMasterTelecaller panelResponsePanelCrmRateMasterTelecaller = PanelResponsePanelCrmRateMasterTelecaller();
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    panelResponsePanelCrmRateMasterTelecaller.id = id;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    panelResponsePanelCrmRateMasterTelecaller.name = name;
  }
  final int? price = jsonConvert.convert<int>(json['price']);
  if (price != null) {
    panelResponsePanelCrmRateMasterTelecaller.price = price;
  }
  final int? valid = jsonConvert.convert<int>(json['valid']);
  if (valid != null) {
    panelResponsePanelCrmRateMasterTelecaller.valid = valid;
  }
  final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
  if (createdAt != null) {
    panelResponsePanelCrmRateMasterTelecaller.createdAt = createdAt;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    panelResponsePanelCrmRateMasterTelecaller.updatedAt = updatedAt;
  }
  return panelResponsePanelCrmRateMasterTelecaller;
}

Map<String, dynamic> $PanelResponsePanelCrmRateMasterTelecallerToJson(
    PanelResponsePanelCrmRateMasterTelecaller entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['_id'] = entity.id;
  data['name'] = entity.name;
  data['price'] = entity.price;
  data['valid'] = entity.valid;
  data['createdAt'] = entity.createdAt;
  data['updatedAt'] = entity.updatedAt;
  return data;
}

extension PanelResponsePanelCrmRateMasterTelecallerExtension on PanelResponsePanelCrmRateMasterTelecaller {
  PanelResponsePanelCrmRateMasterTelecaller copyWith({
    String? id,
    String? name,
    int? price,
    int? valid,
    String? createdAt,
    String? updatedAt,
  }) {
    return PanelResponsePanelCrmRateMasterTelecaller()
      ..id = id ?? this.id
      ..name = name ?? this.name
      ..price = price ?? this.price
      ..valid = valid ?? this.valid
      ..createdAt = createdAt ?? this.createdAt
      ..updatedAt = updatedAt ?? this.updatedAt;
  }
}

PanelResponsePanelTelecaller $PanelResponsePanelTelecallerFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelTelecaller panelResponsePanelTelecaller = PanelResponsePanelTelecaller();
  final PanelResponsePanelTelecallerSupport? support = jsonConvert.convert<
      PanelResponsePanelTelecallerSupport>(json['support']);
  if (support != null) {
    panelResponsePanelTelecaller.support = support;
  }
  final bool? enable = jsonConvert.convert<bool>(json['enable']);
  if (enable != null) {
    panelResponsePanelTelecaller.enable = enable;
  }
  final String? domain = jsonConvert.convert<String>(json['domain']);
  if (domain != null) {
    panelResponsePanelTelecaller.domain = domain;
  }
  final bool? dns = jsonConvert.convert<bool>(json['dns']);
  if (dns != null) {
    panelResponsePanelTelecaller.dns = dns;
  }
  final bool? ssl = jsonConvert.convert<bool>(json['ssl']);
  if (ssl != null) {
    panelResponsePanelTelecaller.ssl = ssl;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    panelResponsePanelTelecaller.name = name;
  }
  final String? description = jsonConvert.convert<String>(json['description']);
  if (description != null) {
    panelResponsePanelTelecaller.description = description;
  }
  final String? slogan = jsonConvert.convert<String>(json['slogan']);
  if (slogan != null) {
    panelResponsePanelTelecaller.slogan = slogan;
  }
  final String? favicon = jsonConvert.convert<String>(json['favicon']);
  if (favicon != null) {
    panelResponsePanelTelecaller.favicon = favicon;
  }
  final String? logo = jsonConvert.convert<String>(json['logo']);
  if (logo != null) {
    panelResponsePanelTelecaller.logo = logo;
  }
  final String? logoLong = jsonConvert.convert<String>(json['logoLong']);
  if (logoLong != null) {
    panelResponsePanelTelecaller.logoLong = logoLong;
  }
  final String? phone = jsonConvert.convert<String>(json['phone']);
  if (phone != null) {
    panelResponsePanelTelecaller.phone = phone;
  }
  final String? email = jsonConvert.convert<String>(json['email']);
  if (email != null) {
    panelResponsePanelTelecaller.email = email;
  }
  final String? address = jsonConvert.convert<String>(json['address']);
  if (address != null) {
    panelResponsePanelTelecaller.address = address;
  }
  final String? country = jsonConvert.convert<String>(json['country']);
  if (country != null) {
    panelResponsePanelTelecaller.country = country;
  }
  final String? dialCode = jsonConvert.convert<String>(json['dialCode']);
  if (dialCode != null) {
    panelResponsePanelTelecaller.dialCode = dialCode;
  }
  final String? language = jsonConvert.convert<String>(json['language']);
  if (language != null) {
    panelResponsePanelTelecaller.language = language;
  }
  final PanelResponsePanelTelecallerSocialMedia? socialMedia = jsonConvert
      .convert<PanelResponsePanelTelecallerSocialMedia>(json['socialMedia']);
  if (socialMedia != null) {
    panelResponsePanelTelecaller.socialMedia = socialMedia;
  }
  final PanelResponsePanelTelecallerTheme? theme = jsonConvert.convert<
      PanelResponsePanelTelecallerTheme>(json['theme']);
  if (theme != null) {
    panelResponsePanelTelecaller.theme = theme;
  }
  final PanelResponsePanelTelecallerCarousel? carousel = jsonConvert.convert<
      PanelResponsePanelTelecallerCarousel>(json['carousel']);
  if (carousel != null) {
    panelResponsePanelTelecaller.carousel = carousel;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    panelResponsePanelTelecaller.updatedAt = updatedAt;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    panelResponsePanelTelecaller.id = id;
  }
  return panelResponsePanelTelecaller;
}

Map<String, dynamic> $PanelResponsePanelTelecallerToJson(
    PanelResponsePanelTelecaller entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['support'] = entity.support?.toJson();
  data['enable'] = entity.enable;
  data['domain'] = entity.domain;
  data['dns'] = entity.dns;
  data['ssl'] = entity.ssl;
  data['name'] = entity.name;
  data['description'] = entity.description;
  data['slogan'] = entity.slogan;
  data['favicon'] = entity.favicon;
  data['logo'] = entity.logo;
  data['logoLong'] = entity.logoLong;
  data['phone'] = entity.phone;
  data['email'] = entity.email;
  data['address'] = entity.address;
  data['country'] = entity.country;
  data['dialCode'] = entity.dialCode;
  data['language'] = entity.language;
  data['socialMedia'] = entity.socialMedia?.toJson();
  data['theme'] = entity.theme?.toJson();
  data['carousel'] = entity.carousel?.toJson();
  data['updatedAt'] = entity.updatedAt;
  data['_id'] = entity.id;
  return data;
}

extension PanelResponsePanelTelecallerExtension on PanelResponsePanelTelecaller {
  PanelResponsePanelTelecaller copyWith({
    PanelResponsePanelTelecallerSupport? support,
    bool? enable,
    String? domain,
    bool? dns,
    bool? ssl,
    String? name,
    String? description,
    String? slogan,
    String? favicon,
    String? logo,
    String? logoLong,
    String? phone,
    String? email,
    String? address,
    String? country,
    String? dialCode,
    String? language,
    PanelResponsePanelTelecallerSocialMedia? socialMedia,
    PanelResponsePanelTelecallerTheme? theme,
    PanelResponsePanelTelecallerCarousel? carousel,
    String? updatedAt,
    String? id,
  }) {
    return PanelResponsePanelTelecaller()
      ..support = support ?? this.support
      ..enable = enable ?? this.enable
      ..domain = domain ?? this.domain
      ..dns = dns ?? this.dns
      ..ssl = ssl ?? this.ssl
      ..name = name ?? this.name
      ..description = description ?? this.description
      ..slogan = slogan ?? this.slogan
      ..favicon = favicon ?? this.favicon
      ..logo = logo ?? this.logo
      ..logoLong = logoLong ?? this.logoLong
      ..phone = phone ?? this.phone
      ..email = email ?? this.email
      ..address = address ?? this.address
      ..country = country ?? this.country
      ..dialCode = dialCode ?? this.dialCode
      ..language = language ?? this.language
      ..socialMedia = socialMedia ?? this.socialMedia
      ..theme = theme ?? this.theme
      ..carousel = carousel ?? this.carousel
      ..updatedAt = updatedAt ?? this.updatedAt
      ..id = id ?? this.id;
  }
}

PanelResponsePanelTelecallerSupport $PanelResponsePanelTelecallerSupportFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelTelecallerSupport panelResponsePanelTelecallerSupport = PanelResponsePanelTelecallerSupport();
  final List<dynamic>? whatsApp = (json['whatsApp'] as List<dynamic>?)?.map(
          (e) => e).toList();
  if (whatsApp != null) {
    panelResponsePanelTelecallerSupport.whatsApp = whatsApp;
  }
  return panelResponsePanelTelecallerSupport;
}

Map<String, dynamic> $PanelResponsePanelTelecallerSupportToJson(
    PanelResponsePanelTelecallerSupport entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['whatsApp'] = entity.whatsApp;
  return data;
}

extension PanelResponsePanelTelecallerSupportExtension on PanelResponsePanelTelecallerSupport {
  PanelResponsePanelTelecallerSupport copyWith({
    List<dynamic>? whatsApp,
  }) {
    return PanelResponsePanelTelecallerSupport()
      ..whatsApp = whatsApp ?? this.whatsApp;
  }
}

PanelResponsePanelTelecallerSocialMedia $PanelResponsePanelTelecallerSocialMediaFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelTelecallerSocialMedia panelResponsePanelTelecallerSocialMedia = PanelResponsePanelTelecallerSocialMedia();
  final String? facebook = jsonConvert.convert<String>(json['facebook']);
  if (facebook != null) {
    panelResponsePanelTelecallerSocialMedia.facebook = facebook;
  }
  final String? instagram = jsonConvert.convert<String>(json['instagram']);
  if (instagram != null) {
    panelResponsePanelTelecallerSocialMedia.instagram = instagram;
  }
  final String? twitter = jsonConvert.convert<String>(json['twitter']);
  if (twitter != null) {
    panelResponsePanelTelecallerSocialMedia.twitter = twitter;
  }
  final String? linkedin = jsonConvert.convert<String>(json['linkedin']);
  if (linkedin != null) {
    panelResponsePanelTelecallerSocialMedia.linkedin = linkedin;
  }
  final String? youtube = jsonConvert.convert<String>(json['youtube']);
  if (youtube != null) {
    panelResponsePanelTelecallerSocialMedia.youtube = youtube;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    panelResponsePanelTelecallerSocialMedia.updatedAt = updatedAt;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    panelResponsePanelTelecallerSocialMedia.id = id;
  }
  return panelResponsePanelTelecallerSocialMedia;
}

Map<String, dynamic> $PanelResponsePanelTelecallerSocialMediaToJson(
    PanelResponsePanelTelecallerSocialMedia entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['facebook'] = entity.facebook;
  data['instagram'] = entity.instagram;
  data['twitter'] = entity.twitter;
  data['linkedin'] = entity.linkedin;
  data['youtube'] = entity.youtube;
  data['updatedAt'] = entity.updatedAt;
  data['_id'] = entity.id;
  return data;
}

extension PanelResponsePanelTelecallerSocialMediaExtension on PanelResponsePanelTelecallerSocialMedia {
  PanelResponsePanelTelecallerSocialMedia copyWith({
    String? facebook,
    String? instagram,
    String? twitter,
    String? linkedin,
    String? youtube,
    String? updatedAt,
    String? id,
  }) {
    return PanelResponsePanelTelecallerSocialMedia()
      ..facebook = facebook ?? this.facebook
      ..instagram = instagram ?? this.instagram
      ..twitter = twitter ?? this.twitter
      ..linkedin = linkedin ?? this.linkedin
      ..youtube = youtube ?? this.youtube
      ..updatedAt = updatedAt ?? this.updatedAt
      ..id = id ?? this.id;
  }
}

PanelResponsePanelTelecallerTheme $PanelResponsePanelTelecallerThemeFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelTelecallerTheme panelResponsePanelTelecallerTheme = PanelResponsePanelTelecallerTheme();
  final String? algorithm = jsonConvert.convert<String>(json['algorithm']);
  if (algorithm != null) {
    panelResponsePanelTelecallerTheme.algorithm = algorithm;
  }
  final PanelResponsePanelTelecallerThemeToken? token = jsonConvert.convert<
      PanelResponsePanelTelecallerThemeToken>(json['token']);
  if (token != null) {
    panelResponsePanelTelecallerTheme.token = token;
  }
  return panelResponsePanelTelecallerTheme;
}

Map<String, dynamic> $PanelResponsePanelTelecallerThemeToJson(
    PanelResponsePanelTelecallerTheme entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['algorithm'] = entity.algorithm;
  data['token'] = entity.token?.toJson();
  return data;
}

extension PanelResponsePanelTelecallerThemeExtension on PanelResponsePanelTelecallerTheme {
  PanelResponsePanelTelecallerTheme copyWith({
    String? algorithm,
    PanelResponsePanelTelecallerThemeToken? token,
  }) {
    return PanelResponsePanelTelecallerTheme()
      ..algorithm = algorithm ?? this.algorithm
      ..token = token ?? this.token;
  }
}

PanelResponsePanelTelecallerThemeToken $PanelResponsePanelTelecallerThemeTokenFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelTelecallerThemeToken panelResponsePanelTelecallerThemeToken = PanelResponsePanelTelecallerThemeToken();
  final String? colorPrimary = jsonConvert.convert<String>(
      json['colorPrimary']);
  if (colorPrimary != null) {
    panelResponsePanelTelecallerThemeToken.colorPrimary = colorPrimary;
  }
  final int? borderRadius = jsonConvert.convert<int>(json['borderRadius']);
  if (borderRadius != null) {
    panelResponsePanelTelecallerThemeToken.borderRadius = borderRadius;
  }
  return panelResponsePanelTelecallerThemeToken;
}

Map<String, dynamic> $PanelResponsePanelTelecallerThemeTokenToJson(
    PanelResponsePanelTelecallerThemeToken entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['colorPrimary'] = entity.colorPrimary;
  data['borderRadius'] = entity.borderRadius;
  return data;
}

extension PanelResponsePanelTelecallerThemeTokenExtension on PanelResponsePanelTelecallerThemeToken {
  PanelResponsePanelTelecallerThemeToken copyWith({
    String? colorPrimary,
    int? borderRadius,
  }) {
    return PanelResponsePanelTelecallerThemeToken()
      ..colorPrimary = colorPrimary ?? this.colorPrimary
      ..borderRadius = borderRadius ?? this.borderRadius;
  }
}

PanelResponsePanelTelecallerCarousel $PanelResponsePanelTelecallerCarouselFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelTelecallerCarousel panelResponsePanelTelecallerCarousel = PanelResponsePanelTelecallerCarousel();
  final bool? enable = jsonConvert.convert<bool>(json['enable']);
  if (enable != null) {
    panelResponsePanelTelecallerCarousel.enable = enable;
  }
  final String? image = jsonConvert.convert<String>(json['image']);
  if (image != null) {
    panelResponsePanelTelecallerCarousel.image = image;
  }
  final String? link = jsonConvert.convert<String>(json['link']);
  if (link != null) {
    panelResponsePanelTelecallerCarousel.link = link;
  }
  final List<dynamic>? items = (json['items'] as List<dynamic>?)?.map(
          (e) => e).toList();
  if (items != null) {
    panelResponsePanelTelecallerCarousel.items = items;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    panelResponsePanelTelecallerCarousel.id = id;
  }
  return panelResponsePanelTelecallerCarousel;
}

Map<String, dynamic> $PanelResponsePanelTelecallerCarouselToJson(
    PanelResponsePanelTelecallerCarousel entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['enable'] = entity.enable;
  data['image'] = entity.image;
  data['link'] = entity.link;
  data['items'] = entity.items;
  data['_id'] = entity.id;
  return data;
}

extension PanelResponsePanelTelecallerCarouselExtension on PanelResponsePanelTelecallerCarousel {
  PanelResponsePanelTelecallerCarousel copyWith({
    bool? enable,
    String? image,
    String? link,
    List<dynamic>? items,
    String? id,
  }) {
    return PanelResponsePanelTelecallerCarousel()
      ..enable = enable ?? this.enable
      ..image = image ?? this.image
      ..link = link ?? this.link
      ..items = items ?? this.items
      ..id = id ?? this.id;
  }
}

PanelResponsePanelCost $PanelResponsePanelCostFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelCost panelResponsePanelCost = PanelResponsePanelCost();
  final int? removeDevice = jsonConvert.convert<int>(json['removeDevice']);
  if (removeDevice != null) {
    panelResponsePanelCost.removeDevice = removeDevice;
  }
  final int? masterOnboarding = jsonConvert.convert<int>(
      json['masterOnboarding']);
  if (masterOnboarding != null) {
    panelResponsePanelCost.masterOnboarding = masterOnboarding;
  }
  final List<
      PanelResponsePanelCostRebranding>? rebranding = (json['rebranding'] as List<
      dynamic>?)?.map(
          (e) =>
      jsonConvert.convert<PanelResponsePanelCostRebranding>(
          e) as PanelResponsePanelCostRebranding).toList();
  if (rebranding != null) {
    panelResponsePanelCost.rebranding = rebranding;
  }
  final int? rebrandingLicense = jsonConvert.convert<int>(
      json['rebrandingLicense']);
  if (rebrandingLicense != null) {
    panelResponsePanelCost.rebrandingLicense = rebrandingLicense;
  }
  return panelResponsePanelCost;
}

Map<String, dynamic> $PanelResponsePanelCostToJson(
    PanelResponsePanelCost entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['removeDevice'] = entity.removeDevice;
  data['masterOnboarding'] = entity.masterOnboarding;
  data['rebranding'] = entity.rebranding?.map((v) => v.toJson()).toList();
  data['rebrandingLicense'] = entity.rebrandingLicense;
  return data;
}

extension PanelResponsePanelCostExtension on PanelResponsePanelCost {
  PanelResponsePanelCost copyWith({
    int? removeDevice,
    int? masterOnboarding,
    List<PanelResponsePanelCostRebranding>? rebranding,
    int? rebrandingLicense,
  }) {
    return PanelResponsePanelCost()
      ..removeDevice = removeDevice ?? this.removeDevice
      ..masterOnboarding = masterOnboarding ?? this.masterOnboarding
      ..rebranding = rebranding ?? this.rebranding
      ..rebrandingLicense = rebrandingLicense ?? this.rebrandingLicense;
  }
}

PanelResponsePanelCostRebranding $PanelResponsePanelCostRebrandingFromJson(
    Map<String, dynamic> json) {
  final PanelResponsePanelCostRebranding panelResponsePanelCostRebranding = PanelResponsePanelCostRebranding();
  final String? productId = jsonConvert.convert<String>(json['productId']);
  if (productId != null) {
    panelResponsePanelCostRebranding.productId = productId;
  }
  final int? cost = jsonConvert.convert<int>(json['cost']);
  if (cost != null) {
    panelResponsePanelCostRebranding.cost = cost;
  }
  return panelResponsePanelCostRebranding;
}

Map<String, dynamic> $PanelResponsePanelCostRebrandingToJson(
    PanelResponsePanelCostRebranding entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['productId'] = entity.productId;
  data['cost'] = entity.cost;
  return data;
}

extension PanelResponsePanelCostRebrandingExtension on PanelResponsePanelCostRebranding {
  PanelResponsePanelCostRebranding copyWith({
    String? productId,
    int? cost,
  }) {
    return PanelResponsePanelCostRebranding()
      ..productId = productId ?? this.productId
      ..cost = cost ?? this.cost;
  }
}