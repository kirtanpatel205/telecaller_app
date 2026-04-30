import 'package:telecaller_app/generated/json/base/json_field.dart';
import 'package:telecaller_app/generated/json/country_drop_response_entity.g.dart';
import 'dart:convert';
export 'package:telecaller_app/generated/json/country_drop_response_entity.g.dart';

@JsonSerializable()
class CountryDropResponseEntity {
	String? countryNameEn = '';
	String? countryNameLocal = '';
	String? countryCode = '';
	String? currencyCode = '';
	String? currencyNameEn = '';
	String? tinType = '';
	String? tinName = '';
	String? officialLanguageCode = '';
	String? officialLanguageNameEn = '';
	String? officialLanguageNameLocal = '';
	String? countryCallingCode = '';
	String? region = '';
	String? flag = '';

	CountryDropResponseEntity();

	factory CountryDropResponseEntity.fromJson(Map<String, dynamic> json) => $CountryDropResponseEntityFromJson(json);

	Map<String, dynamic> toJson() => $CountryDropResponseEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}