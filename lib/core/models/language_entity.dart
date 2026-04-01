import 'package:telecaller_app/generated/json/base/json_field.dart';
import 'package:telecaller_app/generated/json/language_entity.g.dart';
import 'dart:convert';
export 'package:telecaller_app/generated/json/language_entity.g.dart';

@JsonSerializable()
class LanguageEntity {
	String? key = '';
	String? name = '';

	LanguageEntity();

	factory LanguageEntity.fromJson(Map<String, dynamic> json) => $LanguageEntityFromJson(json);

	Map<String, dynamic> toJson() => $LanguageEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}