import 'package:telecaller_app/generated/json/base/json_convert_content.dart';
import 'package:telecaller_app/core/models/save_form_entity.dart';

SaveFormEntity $SaveFormEntityFromJson(Map<String, dynamic> json) {
  final SaveFormEntity saveFormEntity = SaveFormEntity();
  final bool? status = jsonConvert.convert<bool>(json['status']);
  if (status != null) {
    saveFormEntity.status = status;
  }
  final String? message = jsonConvert.convert<String>(json['message']);
  if (message != null) {
    saveFormEntity.message = message;
  }
  final SaveFormResponse? response = jsonConvert.convert<SaveFormResponse>(
      json['response']);
  if (response != null) {
    saveFormEntity.response = response;
  }
  return saveFormEntity;
}

Map<String, dynamic> $SaveFormEntityToJson(SaveFormEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['status'] = entity.status;
  data['message'] = entity.message;
  data['response'] = entity.response?.toJson();
  return data;
}

extension SaveFormEntityExtension on SaveFormEntity {
  SaveFormEntity copyWith({
    bool? status,
    String? message,
    SaveFormResponse? response,
  }) {
    return SaveFormEntity()
      ..status = status ?? this.status
      ..message = message ?? this.message
      ..response = response ?? this.response;
  }
}

SaveFormResponse $SaveFormResponseFromJson(Map<String, dynamic> json) {
  final SaveFormResponse saveFormResponse = SaveFormResponse();
  final String? formId = jsonConvert.convert<String>(json['formId']);
  if (formId != null) {
    saveFormResponse.formId = formId;
  }
  final String? leadId = jsonConvert.convert<String>(json['leadId']);
  if (leadId != null) {
    saveFormResponse.leadId = leadId;
  }
  final String? leadContactId = jsonConvert.convert<String>(
      json['leadContactId']);
  if (leadContactId != null) {
    saveFormResponse.leadContactId = leadContactId;
  }
  final String? assignedTo = jsonConvert.convert<String>(json['assignedTo']);
  if (assignedTo != null) {
    saveFormResponse.assignedTo = assignedTo;
  }
  final String? userId = jsonConvert.convert<String>(json['userId']);
  if (userId != null) {
    saveFormResponse.userId = userId;
  }
  final String? panelId = jsonConvert.convert<String>(json['panelId']);
  if (panelId != null) {
    saveFormResponse.panelId = panelId;
  }
  final List<SaveFormResponseAnswers>? answers = (json['answers'] as List<
      dynamic>?)?.map(
          (e) =>
      jsonConvert.convert<SaveFormResponseAnswers>(
          e) as SaveFormResponseAnswers).toList();
  if (answers != null) {
    saveFormResponse.answers = answers;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    saveFormResponse.id = id;
  }
  final String? submittedAt = jsonConvert.convert<String>(json['submittedAt']);
  if (submittedAt != null) {
    saveFormResponse.submittedAt = submittedAt;
  }
  final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
  if (createdAt != null) {
    saveFormResponse.createdAt = createdAt;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    saveFormResponse.updatedAt = updatedAt;
  }
  final int? v = jsonConvert.convert<int>(json['__v']);
  if (v != null) {
    saveFormResponse.v = v;
  }
  return saveFormResponse;
}

Map<String, dynamic> $SaveFormResponseToJson(SaveFormResponse entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['formId'] = entity.formId;
  data['leadId'] = entity.leadId;
  data['leadContactId'] = entity.leadContactId;
  data['assignedTo'] = entity.assignedTo;
  data['userId'] = entity.userId;
  data['panelId'] = entity.panelId;
  data['answers'] = entity.answers?.map((v) => v.toJson()).toList();
  data['_id'] = entity.id;
  data['submittedAt'] = entity.submittedAt;
  data['createdAt'] = entity.createdAt;
  data['updatedAt'] = entity.updatedAt;
  data['__v'] = entity.v;
  return data;
}

extension SaveFormResponseExtension on SaveFormResponse {
  SaveFormResponse copyWith({
    String? formId,
    String? leadId,
    String? leadContactId,
    String? assignedTo,
    String? userId,
    String? panelId,
    List<SaveFormResponseAnswers>? answers,
    String? id,
    String? submittedAt,
    String? createdAt,
    String? updatedAt,
    int? v,
  }) {
    return SaveFormResponse()
      ..formId = formId ?? this.formId
      ..leadId = leadId ?? this.leadId
      ..leadContactId = leadContactId ?? this.leadContactId
      ..assignedTo = assignedTo ?? this.assignedTo
      ..userId = userId ?? this.userId
      ..panelId = panelId ?? this.panelId
      ..answers = answers ?? this.answers
      ..id = id ?? this.id
      ..submittedAt = submittedAt ?? this.submittedAt
      ..createdAt = createdAt ?? this.createdAt
      ..updatedAt = updatedAt ?? this.updatedAt
      ..v = v ?? this.v;
  }
}

SaveFormResponseAnswers $SaveFormResponseAnswersFromJson(
    Map<String, dynamic> json) {
  final SaveFormResponseAnswers saveFormResponseAnswers = SaveFormResponseAnswers();
  final String? fieldId = jsonConvert.convert<String>(json['fieldId']);
  if (fieldId != null) {
    saveFormResponseAnswers.fieldId = fieldId;
  }
  final String? label = jsonConvert.convert<String>(json['label']);
  if (label != null) {
    saveFormResponseAnswers.label = label;
  }
  final String? type = jsonConvert.convert<String>(json['type']);
  if (type != null) {
    saveFormResponseAnswers.type = type;
  }
  final String? value = jsonConvert.convert<String>(json['value']);
  if (value != null) {
    saveFormResponseAnswers.value = value;
  }
  return saveFormResponseAnswers;
}

Map<String, dynamic> $SaveFormResponseAnswersToJson(
    SaveFormResponseAnswers entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['fieldId'] = entity.fieldId;
  data['label'] = entity.label;
  data['type'] = entity.type;
  data['value'] = entity.value;
  return data;
}

extension SaveFormResponseAnswersExtension on SaveFormResponseAnswers {
  SaveFormResponseAnswers copyWith({
    String? fieldId,
    String? label,
    String? type,
    String? value,
  }) {
    return SaveFormResponseAnswers()
      ..fieldId = fieldId ?? this.fieldId
      ..label = label ?? this.label
      ..type = type ?? this.type
      ..value = value ?? this.value;
  }
}