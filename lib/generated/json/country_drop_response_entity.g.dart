import 'package:telecaller_app/generated/json/base/json_convert_content.dart';
import 'package:telecaller_app/core/models/country_drop_response_entity.dart';

CountryDropResponseEntity $CountryDropResponseEntityFromJson(
    Map<String, dynamic> json) {
  final CountryDropResponseEntity countryDropResponseEntity = CountryDropResponseEntity();
  final String? countryNameEn = jsonConvert.convert<String>(
      json['countryNameEn']);
  if (countryNameEn != null) {
    countryDropResponseEntity.countryNameEn = countryNameEn;
  }
  final String? countryNameLocal = jsonConvert.convert<String>(
      json['countryNameLocal']);
  if (countryNameLocal != null) {
    countryDropResponseEntity.countryNameLocal = countryNameLocal;
  }
  final String? countryCode = jsonConvert.convert<String>(json['countryCode']);
  if (countryCode != null) {
    countryDropResponseEntity.countryCode = countryCode;
  }
  final String? currencyCode = jsonConvert.convert<String>(
      json['currencyCode']);
  if (currencyCode != null) {
    countryDropResponseEntity.currencyCode = currencyCode;
  }
  final String? currencyNameEn = jsonConvert.convert<String>(
      json['currencyNameEn']);
  if (currencyNameEn != null) {
    countryDropResponseEntity.currencyNameEn = currencyNameEn;
  }
  final String? tinType = jsonConvert.convert<String>(json['tinType']);
  if (tinType != null) {
    countryDropResponseEntity.tinType = tinType;
  }
  final String? tinName = jsonConvert.convert<String>(json['tinName']);
  if (tinName != null) {
    countryDropResponseEntity.tinName = tinName;
  }
  final String? officialLanguageCode = jsonConvert.convert<String>(
      json['officialLanguageCode']);
  if (officialLanguageCode != null) {
    countryDropResponseEntity.officialLanguageCode = officialLanguageCode;
  }
  final String? officialLanguageNameEn = jsonConvert.convert<String>(
      json['officialLanguageNameEn']);
  if (officialLanguageNameEn != null) {
    countryDropResponseEntity.officialLanguageNameEn = officialLanguageNameEn;
  }
  final String? officialLanguageNameLocal = jsonConvert.convert<String>(
      json['officialLanguageNameLocal']);
  if (officialLanguageNameLocal != null) {
    countryDropResponseEntity.officialLanguageNameLocal =
        officialLanguageNameLocal;
  }
  final String? countryCallingCode = jsonConvert.convert<String>(
      json['countryCallingCode']);
  if (countryCallingCode != null) {
    countryDropResponseEntity.countryCallingCode = countryCallingCode;
  }
  final String? region = jsonConvert.convert<String>(json['region']);
  if (region != null) {
    countryDropResponseEntity.region = region;
  }
  final String? flag = jsonConvert.convert<String>(json['flag']);
  if (flag != null) {
    countryDropResponseEntity.flag = flag;
  }
  return countryDropResponseEntity;
}

Map<String, dynamic> $CountryDropResponseEntityToJson(
    CountryDropResponseEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['countryNameEn'] = entity.countryNameEn;
  data['countryNameLocal'] = entity.countryNameLocal;
  data['countryCode'] = entity.countryCode;
  data['currencyCode'] = entity.currencyCode;
  data['currencyNameEn'] = entity.currencyNameEn;
  data['tinType'] = entity.tinType;
  data['tinName'] = entity.tinName;
  data['officialLanguageCode'] = entity.officialLanguageCode;
  data['officialLanguageNameEn'] = entity.officialLanguageNameEn;
  data['officialLanguageNameLocal'] = entity.officialLanguageNameLocal;
  data['countryCallingCode'] = entity.countryCallingCode;
  data['region'] = entity.region;
  data['flag'] = entity.flag;
  return data;
}

extension CountryDropResponseEntityExtension on CountryDropResponseEntity {
  CountryDropResponseEntity copyWith({
    String? countryNameEn,
    String? countryNameLocal,
    String? countryCode,
    String? currencyCode,
    String? currencyNameEn,
    String? tinType,
    String? tinName,
    String? officialLanguageCode,
    String? officialLanguageNameEn,
    String? officialLanguageNameLocal,
    String? countryCallingCode,
    String? region,
    String? flag,
  }) {
    return CountryDropResponseEntity()
      ..countryNameEn = countryNameEn ?? this.countryNameEn
      ..countryNameLocal = countryNameLocal ?? this.countryNameLocal
      ..countryCode = countryCode ?? this.countryCode
      ..currencyCode = currencyCode ?? this.currencyCode
      ..currencyNameEn = currencyNameEn ?? this.currencyNameEn
      ..tinType = tinType ?? this.tinType
      ..tinName = tinName ?? this.tinName
      ..officialLanguageCode = officialLanguageCode ?? this.officialLanguageCode
      ..officialLanguageNameEn = officialLanguageNameEn ??
          this.officialLanguageNameEn
      ..officialLanguageNameLocal = officialLanguageNameLocal ??
          this.officialLanguageNameLocal
      ..countryCallingCode = countryCallingCode ?? this.countryCallingCode
      ..region = region ?? this.region
      ..flag = flag ?? this.flag;
  }
}