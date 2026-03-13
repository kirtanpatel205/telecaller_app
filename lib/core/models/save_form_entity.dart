import 'package:telecaller_app/generated/json/base/json_field.dart';
import 'package:telecaller_app/generated/json/save_form_entity.g.dart';
import 'dart:convert';
export 'package:telecaller_app/generated/json/save_form_entity.g.dart';

@JsonSerializable()
class SaveFormEntity {
	bool? status = false;
	String? message = '';
	SaveFormResponse? response;

	SaveFormEntity();

	factory SaveFormEntity.fromJson(Map<String, dynamic> json) => $SaveFormEntityFromJson(json);

	Map<String, dynamic> toJson() => $SaveFormEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class SaveFormResponse {
	String? formId = '';
	String? leadId = '';
	String? leadContactId = '';
	String? assignedTo = '';
	String? userId = '';
	String? panelId = '';
	List<SaveFormResponseAnswers>? answers = [];
	@JSONField(name: '_id')
	String? id = '';
	String? submittedAt = '';
	String? createdAt = '';
	String? updatedAt = '';
	@JSONField(name: '__v')
	int? v = 0;

	SaveFormResponse();

	factory SaveFormResponse.fromJson(Map<String, dynamic> json) => $SaveFormResponseFromJson(json);

	Map<String, dynamic> toJson() => $SaveFormResponseToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class SaveFormResponseAnswers {
	String? fieldId = '';
	String? label = '';
	String? type = '';
	String? value = '';

	SaveFormResponseAnswers();

	factory SaveFormResponseAnswers.fromJson(Map<String, dynamic> json) => $SaveFormResponseAnswersFromJson(json);

	Map<String, dynamic> toJson() => $SaveFormResponseAnswersToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}