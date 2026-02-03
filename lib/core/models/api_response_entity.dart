import 'package:telecaller_app/generated/json/base/json_field.dart';
import 'package:telecaller_app/generated/json/api_response_entity.g.dart';
import 'dart:convert';
export 'package:telecaller_app/generated/json/api_response_entity.g.dart';

@JsonSerializable()
class ApiResponseEntity {
	bool? status = false;
	String? message = '';

	ApiResponseEntity();

	factory ApiResponseEntity.fromJson(Map<String, dynamic> json) => $ApiResponseEntityFromJson(json);

	Map<String, dynamic> toJson() => $ApiResponseEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}