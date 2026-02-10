import 'package:telecaller_app/generated/json/base/json_convert_content.dart';
import 'package:telecaller_app/core/models/all_lead_entity.dart';

AllLeadEntity $AllLeadEntityFromJson(Map<String, dynamic> json) {
  final AllLeadEntity allLeadEntity = AllLeadEntity();
  final bool? status = jsonConvert.convert<bool>(json['status']);
  if (status != null) {
    allLeadEntity.status = status;
  }
  final int? total = jsonConvert.convert<int>(json['total']);
  if (total != null) {
    allLeadEntity.total = total;
  }
  final List<AllLeadLeads>? leads = (json['Leads'] as List<dynamic>?)?.map(
          (e) => jsonConvert.convert<AllLeadLeads>(e) as AllLeadLeads).toList();
  if (leads != null) {
    allLeadEntity.leads = leads;
  }
  return allLeadEntity;
}

Map<String, dynamic> $AllLeadEntityToJson(AllLeadEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['status'] = entity.status;
  data['total'] = entity.total;
  data['Leads'] = entity.leads?.map((v) => v.toJson()).toList();
  return data;
}

extension AllLeadEntityExtension on AllLeadEntity {
  AllLeadEntity copyWith({
    bool? status,
    int? total,
    List<AllLeadLeads>? leads,
  }) {
    return AllLeadEntity()
      ..status = status ?? this.status
      ..total = total ?? this.total
      ..leads = leads ?? this.leads;
  }
}

AllLeadLeads $AllLeadLeadsFromJson(Map<String, dynamic> json) {
  final AllLeadLeads allLeadLeads = AllLeadLeads();
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    allLeadLeads.id = id;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    allLeadLeads.name = name;
  }
  final String? status = jsonConvert.convert<String>(json['status']);
  if (status != null) {
    allLeadLeads.status = status;
  }
  final String? userId = jsonConvert.convert<String>(json['userId']);
  if (userId != null) {
    allLeadLeads.userId = userId;
  }
  final String? panelId = jsonConvert.convert<String>(json['panelId']);
  if (panelId != null) {
    allLeadLeads.panelId = panelId;
  }
  final List<AllLeadLeadsAllot>? allot = (json['allot'] as List<dynamic>?)
      ?.map(
          (e) => jsonConvert.convert<AllLeadLeadsAllot>(e) as AllLeadLeadsAllot)
      .toList();
  if (allot != null) {
    allLeadLeads.allot = allot;
  }
  final AllLeadLeadsSchedule? schedule = jsonConvert.convert<
      AllLeadLeadsSchedule>(json['schedule']);
  if (schedule != null) {
    allLeadLeads.schedule = schedule;
  }
  final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
  if (createdAt != null) {
    allLeadLeads.createdAt = createdAt;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    allLeadLeads.updatedAt = updatedAt;
  }
  final int? v = jsonConvert.convert<int>(json['__v']);
  if (v != null) {
    allLeadLeads.v = v;
  }
  final AllLeadLeadsFormId? formId = jsonConvert.convert<AllLeadLeadsFormId>(
      json['formId']);
  if (formId != null) {
    allLeadLeads.formId = formId;
  }
  return allLeadLeads;
}

Map<String, dynamic> $AllLeadLeadsToJson(AllLeadLeads entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['_id'] = entity.id;
  data['name'] = entity.name;
  data['status'] = entity.status;
  data['userId'] = entity.userId;
  data['panelId'] = entity.panelId;
  data['allot'] = entity.allot?.map((v) => v.toJson()).toList();
  data['schedule'] = entity.schedule?.toJson();
  data['createdAt'] = entity.createdAt;
  data['updatedAt'] = entity.updatedAt;
  data['__v'] = entity.v;
  data['formId'] = entity.formId?.toJson();
  return data;
}

extension AllLeadLeadsExtension on AllLeadLeads {
  AllLeadLeads copyWith({
    String? id,
    String? name,
    String? status,
    String? userId,
    String? panelId,
    List<AllLeadLeadsAllot>? allot,
    AllLeadLeadsSchedule? schedule,
    String? createdAt,
    String? updatedAt,
    int? v,
    AllLeadLeadsFormId? formId,
  }) {
    return AllLeadLeads()
      ..id = id ?? this.id
      ..name = name ?? this.name
      ..status = status ?? this.status
      ..userId = userId ?? this.userId
      ..panelId = panelId ?? this.panelId
      ..allot = allot ?? this.allot
      ..schedule = schedule ?? this.schedule
      ..createdAt = createdAt ?? this.createdAt
      ..updatedAt = updatedAt ?? this.updatedAt
      ..v = v ?? this.v
      ..formId = formId ?? this.formId;
  }
}

AllLeadLeadsAllot $AllLeadLeadsAllotFromJson(Map<String, dynamic> json) {
  final AllLeadLeadsAllot allLeadLeadsAllot = AllLeadLeadsAllot();
  final AllLeadLeadsAllotUserId? userId = jsonConvert.convert<
      AllLeadLeadsAllotUserId>(json['userId']);
  if (userId != null) {
    allLeadLeadsAllot.userId = userId;
  }
  final int? value = jsonConvert.convert<int>(json['value']);
  if (value != null) {
    allLeadLeadsAllot.value = value;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    allLeadLeadsAllot.id = id;
  }
  return allLeadLeadsAllot;
}

Map<String, dynamic> $AllLeadLeadsAllotToJson(AllLeadLeadsAllot entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['userId'] = entity.userId?.toJson();
  data['value'] = entity.value;
  data['_id'] = entity.id;
  return data;
}

extension AllLeadLeadsAllotExtension on AllLeadLeadsAllot {
  AllLeadLeadsAllot copyWith({
    AllLeadLeadsAllotUserId? userId,
    int? value,
    String? id,
  }) {
    return AllLeadLeadsAllot()
      ..userId = userId ?? this.userId
      ..value = value ?? this.value
      ..id = id ?? this.id;
  }
}

AllLeadLeadsAllotUserId $AllLeadLeadsAllotUserIdFromJson(
    Map<String, dynamic> json) {
  final AllLeadLeadsAllotUserId allLeadLeadsAllotUserId = AllLeadLeadsAllotUserId();
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    allLeadLeadsAllotUserId.id = id;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    allLeadLeadsAllotUserId.name = name;
  }
  final String? phone = jsonConvert.convert<String>(json['phone']);
  if (phone != null) {
    allLeadLeadsAllotUserId.phone = phone;
  }
  final String? profile = jsonConvert.convert<String>(json['profile']);
  if (profile != null) {
    allLeadLeadsAllotUserId.profile = profile;
  }
  final String? email = jsonConvert.convert<String>(json['email']);
  if (email != null) {
    allLeadLeadsAllotUserId.email = email;
  }
  return allLeadLeadsAllotUserId;
}

Map<String, dynamic> $AllLeadLeadsAllotUserIdToJson(
    AllLeadLeadsAllotUserId entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['_id'] = entity.id;
  data['name'] = entity.name;
  data['phone'] = entity.phone;
  data['profile'] = entity.profile;
  data['email'] = entity.email;
  return data;
}

extension AllLeadLeadsAllotUserIdExtension on AllLeadLeadsAllotUserId {
  AllLeadLeadsAllotUserId copyWith({
    String? id,
    String? name,
    String? phone,
    String? profile,
    String? email,
  }) {
    return AllLeadLeadsAllotUserId()
      ..id = id ?? this.id
      ..name = name ?? this.name
      ..phone = phone ?? this.phone
      ..profile = profile ?? this.profile
      ..email = email ?? this.email;
  }
}

AllLeadLeadsSchedule $AllLeadLeadsScheduleFromJson(Map<String, dynamic> json) {
  final AllLeadLeadsSchedule allLeadLeadsSchedule = AllLeadLeadsSchedule();
  final String? type = jsonConvert.convert<String>(json['type']);
  if (type != null) {
    allLeadLeadsSchedule.type = type;
  }
  final String? startDate = jsonConvert.convert<String>(json['startDate']);
  if (startDate != null) {
    allLeadLeadsSchedule.startDate = startDate;
  }
  final String? endDate = jsonConvert.convert<String>(json['endDate']);
  if (endDate != null) {
    allLeadLeadsSchedule.endDate = endDate;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    allLeadLeadsSchedule.id = id;
  }
  return allLeadLeadsSchedule;
}

Map<String, dynamic> $AllLeadLeadsScheduleToJson(AllLeadLeadsSchedule entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['type'] = entity.type;
  data['startDate'] = entity.startDate;
  data['endDate'] = entity.endDate;
  data['_id'] = entity.id;
  return data;
}

extension AllLeadLeadsScheduleExtension on AllLeadLeadsSchedule {
  AllLeadLeadsSchedule copyWith({
    String? type,
    String? startDate,
    String? endDate,
    String? id,
  }) {
    return AllLeadLeadsSchedule()
      ..type = type ?? this.type
      ..startDate = startDate ?? this.startDate
      ..endDate = endDate ?? this.endDate
      ..id = id ?? this.id;
  }
}

AllLeadLeadsFormId $AllLeadLeadsFormIdFromJson(Map<String, dynamic> json) {
  final AllLeadLeadsFormId allLeadLeadsFormId = AllLeadLeadsFormId();
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    allLeadLeadsFormId.id = id;
  }
  final String? title = jsonConvert.convert<String>(json['title']);
  if (title != null) {
    allLeadLeadsFormId.title = title;
  }
  final String? description = jsonConvert.convert<String>(json['description']);
  if (description != null) {
    allLeadLeadsFormId.description = description;
  }
  final List<AllLeadLeadsFormIdFields>? fields = (json['fields'] as List<
      dynamic>?)?.map(
          (e) =>
      jsonConvert.convert<AllLeadLeadsFormIdFields>(
          e) as AllLeadLeadsFormIdFields).toList();
  if (fields != null) {
    allLeadLeadsFormId.fields = fields;
  }
  final String? userId = jsonConvert.convert<String>(json['userId']);
  if (userId != null) {
    allLeadLeadsFormId.userId = userId;
  }
  final String? panelId = jsonConvert.convert<String>(json['panelId']);
  if (panelId != null) {
    allLeadLeadsFormId.panelId = panelId;
  }
  final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
  if (createdAt != null) {
    allLeadLeadsFormId.createdAt = createdAt;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    allLeadLeadsFormId.updatedAt = updatedAt;
  }
  final int? v = jsonConvert.convert<int>(json['__v']);
  if (v != null) {
    allLeadLeadsFormId.v = v;
  }
  return allLeadLeadsFormId;
}

Map<String, dynamic> $AllLeadLeadsFormIdToJson(AllLeadLeadsFormId entity) {
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

extension AllLeadLeadsFormIdExtension on AllLeadLeadsFormId {
  AllLeadLeadsFormId copyWith({
    String? id,
    String? title,
    String? description,
    List<AllLeadLeadsFormIdFields>? fields,
    String? userId,
    String? panelId,
    String? createdAt,
    String? updatedAt,
    int? v,
  }) {
    return AllLeadLeadsFormId()
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

AllLeadLeadsFormIdFields $AllLeadLeadsFormIdFieldsFromJson(
    Map<String, dynamic> json) {
  final AllLeadLeadsFormIdFields allLeadLeadsFormIdFields = AllLeadLeadsFormIdFields();
  final String? type = jsonConvert.convert<String>(json['type']);
  if (type != null) {
    allLeadLeadsFormIdFields.type = type;
  }
  final String? label = jsonConvert.convert<String>(json['label']);
  if (label != null) {
    allLeadLeadsFormIdFields.label = label;
  }
  final String? placeholder = jsonConvert.convert<String>(json['placeholder']);
  if (placeholder != null) {
    allLeadLeadsFormIdFields.placeholder = placeholder;
  }
  final bool? required = jsonConvert.convert<bool>(json['required']);
  if (required != null) {
    allLeadLeadsFormIdFields.required = required;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    allLeadLeadsFormIdFields.id = id;
  }
  final List<String>? options = (json['options'] as List<dynamic>?)?.map(
          (e) => jsonConvert.convert<String>(e) as String).toList();
  if (options != null) {
    allLeadLeadsFormIdFields.options = options;
  }
  return allLeadLeadsFormIdFields;
}

Map<String, dynamic> $AllLeadLeadsFormIdFieldsToJson(
    AllLeadLeadsFormIdFields entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['type'] = entity.type;
  data['label'] = entity.label;
  data['placeholder'] = entity.placeholder;
  data['required'] = entity.required;
  data['_id'] = entity.id;
  data['options'] = entity.options;
  return data;
}

extension AllLeadLeadsFormIdFieldsExtension on AllLeadLeadsFormIdFields {
  AllLeadLeadsFormIdFields copyWith({
    String? type,
    String? label,
    String? placeholder,
    bool? required,
    String? id,
    List<String>? options,
  }) {
    return AllLeadLeadsFormIdFields()
      ..type = type ?? this.type
      ..label = label ?? this.label
      ..placeholder = placeholder ?? this.placeholder
      ..required = required ?? this.required
      ..id = id ?? this.id
      ..options = options ?? this.options;
  }
}