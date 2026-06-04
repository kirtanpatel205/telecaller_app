import 'package:telecaller_app/generated/json/base/json_convert_content.dart';
import 'package:telecaller_app/core/models/form_response_entity.dart';

FormResponseEntity $FormResponseEntityFromJson(Map<String, dynamic> json) {
  final FormResponseEntity formResponseEntity = FormResponseEntity();
  final bool? status = jsonConvert.convert<bool>(json['status']);
  if (status != null) {
    formResponseEntity.status = status;
  }
  final FormResponseFormResponse? formResponse = jsonConvert.convert<
      FormResponseFormResponse>(json['formResponse']);
  if (formResponse != null) {
    formResponseEntity.formResponse = formResponse;
  }
  return formResponseEntity;
}

Map<String, dynamic> $FormResponseEntityToJson(FormResponseEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['status'] = entity.status;
  data['formResponse'] = entity.formResponse?.toJson();
  return data;
}

extension FormResponseEntityExtension on FormResponseEntity {
  FormResponseEntity copyWith({
    bool? status,
    FormResponseFormResponse? formResponse,
  }) {
    return FormResponseEntity()
      ..status = status ?? this.status
      ..formResponse = formResponse ?? this.formResponse;
  }
}

FormResponseFormResponse $FormResponseFormResponseFromJson(
    Map<String, dynamic> json) {
  final FormResponseFormResponse formResponseFormResponse = FormResponseFormResponse();
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    formResponseFormResponse.id = id;
  }
  final FormResponseFormResponseFormId? formId = jsonConvert.convert<
      FormResponseFormResponseFormId>(json['formId']);
  if (formId != null) {
    formResponseFormResponse.formId = formId;
  }
  final String? leadId = jsonConvert.convert<String>(json['leadId']);
  if (leadId != null) {
    formResponseFormResponse.leadId = leadId;
  }
  final String? leadContactId = jsonConvert.convert<String>(
      json['leadContactId']);
  if (leadContactId != null) {
    formResponseFormResponse.leadContactId = leadContactId;
  }
  final FormResponseFormResponseAssignedTo? assignedTo = jsonConvert.convert<
      FormResponseFormResponseAssignedTo>(json['assignedTo']);
  if (assignedTo != null) {
    formResponseFormResponse.assignedTo = assignedTo;
  }
  final String? userId = jsonConvert.convert<String>(json['userId']);
  if (userId != null) {
    formResponseFormResponse.userId = userId;
  }
  final String? panelId = jsonConvert.convert<String>(json['panelId']);
  if (panelId != null) {
    formResponseFormResponse.panelId = panelId;
  }
  final List<
      FormResponseFormResponseAnswers>? answers = (json['answers'] as List<
      dynamic>?)?.map(
          (e) =>
      jsonConvert.convert<FormResponseFormResponseAnswers>(
          e) as FormResponseFormResponseAnswers).toList();
  if (answers != null) {
    formResponseFormResponse.answers = answers;
  }
  final String? submittedAt = jsonConvert.convert<String>(json['submittedAt']);
  if (submittedAt != null) {
    formResponseFormResponse.submittedAt = submittedAt;
  }
  final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
  if (createdAt != null) {
    formResponseFormResponse.createdAt = createdAt;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    formResponseFormResponse.updatedAt = updatedAt;
  }
  final int? v = jsonConvert.convert<int>(json['__v']);
  if (v != null) {
    formResponseFormResponse.v = v;
  }
  return formResponseFormResponse;
}

Map<String, dynamic> $FormResponseFormResponseToJson(
    FormResponseFormResponse entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['_id'] = entity.id;
  data['formId'] = entity.formId?.toJson();
  data['leadId'] = entity.leadId;
  data['leadContactId'] = entity.leadContactId;
  data['assignedTo'] = entity.assignedTo?.toJson();
  data['userId'] = entity.userId;
  data['panelId'] = entity.panelId;
  data['answers'] = entity.answers?.map((v) => v.toJson()).toList();
  data['submittedAt'] = entity.submittedAt;
  data['createdAt'] = entity.createdAt;
  data['updatedAt'] = entity.updatedAt;
  data['__v'] = entity.v;
  return data;
}

extension FormResponseFormResponseExtension on FormResponseFormResponse {
  FormResponseFormResponse copyWith({
    String? id,
    FormResponseFormResponseFormId? formId,
    String? leadId,
    String? leadContactId,
    FormResponseFormResponseAssignedTo? assignedTo,
    String? userId,
    String? panelId,
    List<FormResponseFormResponseAnswers>? answers,
    String? submittedAt,
    String? createdAt,
    String? updatedAt,
    int? v,
  }) {
    return FormResponseFormResponse()
      ..id = id ?? this.id
      ..formId = formId ?? this.formId
      ..leadId = leadId ?? this.leadId
      ..leadContactId = leadContactId ?? this.leadContactId
      ..assignedTo = assignedTo ?? this.assignedTo
      ..userId = userId ?? this.userId
      ..panelId = panelId ?? this.panelId
      ..answers = answers ?? this.answers
      ..submittedAt = submittedAt ?? this.submittedAt
      ..createdAt = createdAt ?? this.createdAt
      ..updatedAt = updatedAt ?? this.updatedAt
      ..v = v ?? this.v;
  }
}

FormResponseFormResponseFormId $FormResponseFormResponseFormIdFromJson(
    Map<String, dynamic> json) {
  final FormResponseFormResponseFormId formResponseFormResponseFormId = FormResponseFormResponseFormId();
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    formResponseFormResponseFormId.id = id;
  }
  final String? title = jsonConvert.convert<String>(json['title']);
  if (title != null) {
    formResponseFormResponseFormId.title = title;
  }
  final String? description = jsonConvert.convert<String>(json['description']);
  if (description != null) {
    formResponseFormResponseFormId.description = description;
  }
  final List<
      FormResponseFormResponseFormIdFields>? fields = (json['fields'] as List<
      dynamic>?)?.map(
          (e) =>
      jsonConvert.convert<FormResponseFormResponseFormIdFields>(
          e) as FormResponseFormResponseFormIdFields).toList();
  if (fields != null) {
    formResponseFormResponseFormId.fields = fields;
  }
  final String? userId = jsonConvert.convert<String>(json['userId']);
  if (userId != null) {
    formResponseFormResponseFormId.userId = userId;
  }
  final String? panelId = jsonConvert.convert<String>(json['panelId']);
  if (panelId != null) {
    formResponseFormResponseFormId.panelId = panelId;
  }
  final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
  if (createdAt != null) {
    formResponseFormResponseFormId.createdAt = createdAt;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    formResponseFormResponseFormId.updatedAt = updatedAt;
  }
  final int? v = jsonConvert.convert<int>(json['__v']);
  if (v != null) {
    formResponseFormResponseFormId.v = v;
  }
  return formResponseFormResponseFormId;
}

Map<String, dynamic> $FormResponseFormResponseFormIdToJson(
    FormResponseFormResponseFormId entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['_id'] = entity.id;
  data['title'] = entity.title;
  data['description'] = entity.description;
  data['fields'] = entity.fields?.map((v) => v.toJson()).toList();
  data['userId'] = entity.userId;
  data['panelId'] = entity.panelId;
  data['createdAt'] = entity.createdAt;
  data['updatedAt'] = entity.updatedAt;
  data['__v'] = entity.v;
  return data;
}

extension FormResponseFormResponseFormIdExtension on FormResponseFormResponseFormId {
  FormResponseFormResponseFormId copyWith({
    String? id,
    String? title,
    String? description,
    List<FormResponseFormResponseFormIdFields>? fields,
    String? userId,
    String? panelId,
    String? createdAt,
    String? updatedAt,
    int? v,
  }) {
    return FormResponseFormResponseFormId()
      ..id = id ?? this.id
      ..title = title ?? this.title
      ..description = description ?? this.description
      ..fields = fields ?? this.fields
      ..userId = userId ?? this.userId
      ..panelId = panelId ?? this.panelId
      ..createdAt = createdAt ?? this.createdAt
      ..updatedAt = updatedAt ?? this.updatedAt
      ..v = v ?? this.v;
  }
}

FormResponseFormResponseFormIdFields $FormResponseFormResponseFormIdFieldsFromJson(
    Map<String, dynamic> json) {
  final FormResponseFormResponseFormIdFields formResponseFormResponseFormIdFields = FormResponseFormResponseFormIdFields();
  final String? type = jsonConvert.convert<String>(json['type']);
  if (type != null) {
    formResponseFormResponseFormIdFields.type = type;
  }
  final String? label = jsonConvert.convert<String>(json['label']);
  if (label != null) {
    formResponseFormResponseFormIdFields.label = label;
  }
  final String? placeholder = jsonConvert.convert<String>(json['placeholder']);
  if (placeholder != null) {
    formResponseFormResponseFormIdFields.placeholder = placeholder;
  }
  final bool? required = jsonConvert.convert<bool>(json['required']);
  if (required != null) {
    formResponseFormResponseFormIdFields.required = required;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    formResponseFormResponseFormIdFields.id = id;
  }
  final List<String>? options = (json['options'] as List<dynamic>?)?.map(
          (e) => jsonConvert.convert<String>(e) as String).toList();
  if (options != null) {
    formResponseFormResponseFormIdFields.options = options;
  }
  return formResponseFormResponseFormIdFields;
}

Map<String, dynamic> $FormResponseFormResponseFormIdFieldsToJson(
    FormResponseFormResponseFormIdFields entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['type'] = entity.type;
  data['label'] = entity.label;
  data['placeholder'] = entity.placeholder;
  data['required'] = entity.required;
  data['_id'] = entity.id;
  data['options'] = entity.options;
  return data;
}

extension FormResponseFormResponseFormIdFieldsExtension on FormResponseFormResponseFormIdFields {
  FormResponseFormResponseFormIdFields copyWith({
    String? type,
    String? label,
    String? placeholder,
    bool? required,
    String? id,
    List<String>? options,
  }) {
    return FormResponseFormResponseFormIdFields()
      ..type = type ?? this.type
      ..label = label ?? this.label
      ..placeholder = placeholder ?? this.placeholder
      ..required = required ?? this.required
      ..id = id ?? this.id
      ..options = options ?? this.options;
  }
}

FormResponseFormResponseAssignedTo $FormResponseFormResponseAssignedToFromJson(
    Map<String, dynamic> json) {
  final FormResponseFormResponseAssignedTo formResponseFormResponseAssignedTo = FormResponseFormResponseAssignedTo();
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    formResponseFormResponseAssignedTo.id = id;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    formResponseFormResponseAssignedTo.name = name;
  }
  final String? phone = jsonConvert.convert<String>(json['phone']);
  if (phone != null) {
    formResponseFormResponseAssignedTo.phone = phone;
  }
  final String? profile = jsonConvert.convert<String>(json['profile']);
  if (profile != null) {
    formResponseFormResponseAssignedTo.profile = profile;
  }
  final String? email = jsonConvert.convert<String>(json['email']);
  if (email != null) {
    formResponseFormResponseAssignedTo.email = email;
  }
  return formResponseFormResponseAssignedTo;
}

Map<String, dynamic> $FormResponseFormResponseAssignedToToJson(
    FormResponseFormResponseAssignedTo entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['_id'] = entity.id;
  data['name'] = entity.name;
  data['phone'] = entity.phone;
  data['profile'] = entity.profile;
  data['email'] = entity.email;
  return data;
}

extension FormResponseFormResponseAssignedToExtension on FormResponseFormResponseAssignedTo {
  FormResponseFormResponseAssignedTo copyWith({
    String? id,
    String? name,
    String? phone,
    String? profile,
    String? email,
  }) {
    return FormResponseFormResponseAssignedTo()
      ..id = id ?? this.id
      ..name = name ?? this.name
      ..phone = phone ?? this.phone
      ..profile = profile ?? this.profile
      ..email = email ?? this.email;
  }
}

FormResponseFormResponseAnswers $FormResponseFormResponseAnswersFromJson(
    Map<String, dynamic> json) {
  final FormResponseFormResponseAnswers formResponseFormResponseAnswers = FormResponseFormResponseAnswers();
  final String? fieldId = jsonConvert.convert<String>(json['fieldId']);
  if (fieldId != null) {
    formResponseFormResponseAnswers.fieldId = fieldId;
  }
  final String? label = jsonConvert.convert<String>(json['label']);
  if (label != null) {
    formResponseFormResponseAnswers.label = label;
  }
  final String? type = jsonConvert.convert<String>(json['type']);
  if (type != null) {
    formResponseFormResponseAnswers.type = type;
  }
  final dynamic value = json['value'];
  if (value != null) {
    formResponseFormResponseAnswers.value = value;
  }
  return formResponseFormResponseAnswers;
}

Map<String, dynamic> $FormResponseFormResponseAnswersToJson(
    FormResponseFormResponseAnswers entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['fieldId'] = entity.fieldId;
  data['label'] = entity.label;
  data['type'] = entity.type;
  data['value'] = entity.value;
  return data;
}

extension FormResponseFormResponseAnswersExtension on FormResponseFormResponseAnswers {
  FormResponseFormResponseAnswers copyWith({
    String? fieldId,
    String? label,
    String? type,
    dynamic value,
  }) {
    return FormResponseFormResponseAnswers()
      ..fieldId = fieldId ?? this.fieldId
      ..label = label ?? this.label
      ..type = type ?? this.type
      ..value = value ?? this.value;
  }
}