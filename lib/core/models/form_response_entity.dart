import 'package:telecaller_app/generated/json/base/json_field.dart';
import 'package:telecaller_app/generated/json/form_response_entity.g.dart';
import 'dart:convert';
export 'package:telecaller_app/generated/json/form_response_entity.g.dart';

@JsonSerializable()
class FormResponseEntity {
	bool? status = false;
	FormResponseFormResponse? formResponse;

	FormResponseEntity();

	factory FormResponseEntity.fromJson(Map<String, dynamic> json) => $FormResponseEntityFromJson(json);

	Map<String, dynamic> toJson() => $FormResponseEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class FormResponseFormResponse {
	@JSONField(name: '_id')
	String? id = '';
	FormResponseFormResponseFormId? formId;
	String? leadId = '';
	String? leadContactId = '';
	FormResponseFormResponseAssignedTo? assignedTo;
	String? userId = '';
	String? panelId = '';
	List<FormResponseFormResponseAnswers>? answers = [];
	String? submittedAt = '';
	String? createdAt = '';
	String? updatedAt = '';
	@JSONField(name: '__v')
	int? v = 0;

	FormResponseFormResponse();

	factory FormResponseFormResponse.fromJson(Map<String, dynamic> json) => $FormResponseFormResponseFromJson(json);

	Map<String, dynamic> toJson() => $FormResponseFormResponseToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class FormResponseFormResponseFormId {
	@JSONField(name: '_id')
	String? id = '';
	String? title = '';
	String? description = '';
	List<FormResponseFormResponseFormIdFields>? fields = [];
	String? userId = '';
	String? panelId = '';
	String? createdAt = '';
	String? updatedAt = '';
	@JSONField(name: '__v')
	int? v = 0;

	FormResponseFormResponseFormId();

	factory FormResponseFormResponseFormId.fromJson(Map<String, dynamic> json) => $FormResponseFormResponseFormIdFromJson(json);

	Map<String, dynamic> toJson() => $FormResponseFormResponseFormIdToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class FormResponseFormResponseFormIdFields {
	String? type = '';
	String? label = '';
	String? placeholder = '';
	bool? required = false;
	@JSONField(name: '_id')
	String? id = '';
	List<String>? options = [];

	FormResponseFormResponseFormIdFields();

	factory FormResponseFormResponseFormIdFields.fromJson(Map<String, dynamic> json) => $FormResponseFormResponseFormIdFieldsFromJson(json);

	Map<String, dynamic> toJson() => $FormResponseFormResponseFormIdFieldsToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class FormResponseFormResponseAssignedTo {
	@JSONField(name: '_id')
	String? id = '';
	String? name = '';
	String? phone = '';
	String? profile = '';
	String? email = '';

	FormResponseFormResponseAssignedTo();

	factory FormResponseFormResponseAssignedTo.fromJson(Map<String, dynamic> json) => $FormResponseFormResponseAssignedToFromJson(json);

	Map<String, dynamic> toJson() => $FormResponseFormResponseAssignedToToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class FormResponseFormResponseAnswers {
	String? fieldId = '';
	String? label = '';
	String? type = '';
	dynamic value;

	FormResponseFormResponseAnswers();

	factory FormResponseFormResponseAnswers.fromJson(Map<String, dynamic> json) => $FormResponseFormResponseAnswersFromJson(json);

	Map<String, dynamic> toJson() => $FormResponseFormResponseAnswersToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}