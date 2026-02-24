import 'package:telecaller_app/generated/json/base/json_convert_content.dart';
import 'package:telecaller_app/core/models/call_lead_update_response_entity.dart';

CallLeadUpdateResponseEntity $CallLeadUpdateResponseEntityFromJson(
    Map<String, dynamic> json) {
  final CallLeadUpdateResponseEntity callLeadUpdateResponseEntity = CallLeadUpdateResponseEntity();
  final bool? status = jsonConvert.convert<bool>(json['status']);
  if (status != null) {
    callLeadUpdateResponseEntity.status = status;
  }
  final CallLeadUpdateResponseData? data = jsonConvert.convert<
      CallLeadUpdateResponseData>(json['data']);
  if (data != null) {
    callLeadUpdateResponseEntity.data = data;
  }
  return callLeadUpdateResponseEntity;
}

Map<String, dynamic> $CallLeadUpdateResponseEntityToJson(
    CallLeadUpdateResponseEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['status'] = entity.status;
  data['data'] = entity.data?.toJson();
  return data;
}

extension CallLeadUpdateResponseEntityExtension on CallLeadUpdateResponseEntity {
  CallLeadUpdateResponseEntity copyWith({
    bool? status,
    CallLeadUpdateResponseData? data,
  }) {
    return CallLeadUpdateResponseEntity()
      ..status = status ?? this.status
      ..data = data ?? this.data;
  }
}

CallLeadUpdateResponseData $CallLeadUpdateResponseDataFromJson(
    Map<String, dynamic> json) {
  final CallLeadUpdateResponseData callLeadUpdateResponseData = CallLeadUpdateResponseData();
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    callLeadUpdateResponseData.id = id;
  }
  final String? leadId = jsonConvert.convert<String>(json['leadId']);
  if (leadId != null) {
    callLeadUpdateResponseData.leadId = leadId;
  }
  final String? userId = jsonConvert.convert<String>(json['userId']);
  if (userId != null) {
    callLeadUpdateResponseData.userId = userId;
  }
  final String? panelId = jsonConvert.convert<String>(json['panelId']);
  if (panelId != null) {
    callLeadUpdateResponseData.panelId = panelId;
  }
  final String? assignedTo = jsonConvert.convert<String>(json['assignedTo']);
  if (assignedTo != null) {
    callLeadUpdateResponseData.assignedTo = assignedTo;
  }
  final String? status = jsonConvert.convert<String>(json['status']);
  if (status != null) {
    callLeadUpdateResponseData.status = status;
  }
  final String? scheduleAt = jsonConvert.convert<String>(json['scheduleAt']);
  if (scheduleAt != null) {
    callLeadUpdateResponseData.scheduleAt = scheduleAt;
  }
  final CallLeadUpdateResponseDataContact? contact = jsonConvert.convert<
      CallLeadUpdateResponseDataContact>(json['contact']);
  if (contact != null) {
    callLeadUpdateResponseData.contact = contact;
  }
  final List<CallLeadUpdateResponseDataLogs>? logs = (json['logs'] as List<
      dynamic>?)?.map(
          (e) =>
      jsonConvert.convert<CallLeadUpdateResponseDataLogs>(
          e) as CallLeadUpdateResponseDataLogs).toList();
  if (logs != null) {
    callLeadUpdateResponseData.logs = logs;
  }
  final int? v = jsonConvert.convert<int>(json['__v']);
  if (v != null) {
    callLeadUpdateResponseData.v = v;
  }
  final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
  if (createdAt != null) {
    callLeadUpdateResponseData.createdAt = createdAt;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    callLeadUpdateResponseData.updatedAt = updatedAt;
  }
  return callLeadUpdateResponseData;
}

Map<String, dynamic> $CallLeadUpdateResponseDataToJson(
    CallLeadUpdateResponseData entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['_id'] = entity.id;
  data['leadId'] = entity.leadId;
  data['userId'] = entity.userId;
  data['panelId'] = entity.panelId;
  data['assignedTo'] = entity.assignedTo;
  data['status'] = entity.status;
  data['scheduleAt'] = entity.scheduleAt;
  data['contact'] = entity.contact?.toJson();
  data['logs'] = entity.logs?.map((v) => v.toJson()).toList();
  data['__v'] = entity.v;
  data['createdAt'] = entity.createdAt;
  data['updatedAt'] = entity.updatedAt;
  return data;
}

extension CallLeadUpdateResponseDataExtension on CallLeadUpdateResponseData {
  CallLeadUpdateResponseData copyWith({
    String? id,
    String? leadId,
    String? userId,
    String? panelId,
    String? assignedTo,
    String? status,
    String? scheduleAt,
    CallLeadUpdateResponseDataContact? contact,
    List<CallLeadUpdateResponseDataLogs>? logs,
    int? v,
    String? createdAt,
    String? updatedAt,
  }) {
    return CallLeadUpdateResponseData()
      ..id = id ?? this.id
      ..leadId = leadId ?? this.leadId
      ..userId = userId ?? this.userId
      ..panelId = panelId ?? this.panelId
      ..assignedTo = assignedTo ?? this.assignedTo
      ..status = status ?? this.status
      ..scheduleAt = scheduleAt ?? this.scheduleAt
      ..contact = contact ?? this.contact
      ..logs = logs ?? this.logs
      ..v = v ?? this.v
      ..createdAt = createdAt ?? this.createdAt
      ..updatedAt = updatedAt ?? this.updatedAt;
  }
}

CallLeadUpdateResponseDataContact $CallLeadUpdateResponseDataContactFromJson(
    Map<String, dynamic> json) {
  final CallLeadUpdateResponseDataContact callLeadUpdateResponseDataContact = CallLeadUpdateResponseDataContact();
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    callLeadUpdateResponseDataContact.name = name;
  }
  final String? email = jsonConvert.convert<String>(json['email']);
  if (email != null) {
    callLeadUpdateResponseDataContact.email = email;
  }
  final String? phone = jsonConvert.convert<String>(json['phone']);
  if (phone != null) {
    callLeadUpdateResponseDataContact.phone = phone;
  }
  final String? city = jsonConvert.convert<String>(json['city']);
  if (city != null) {
    callLeadUpdateResponseDataContact.city = city;
  }
  final String? state = jsonConvert.convert<String>(json['state']);
  if (state != null) {
    callLeadUpdateResponseDataContact.state = state;
  }
  final String? country = jsonConvert.convert<String>(json['country']);
  if (country != null) {
    callLeadUpdateResponseDataContact.country = country;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    callLeadUpdateResponseDataContact.id = id;
  }
  return callLeadUpdateResponseDataContact;
}

Map<String, dynamic> $CallLeadUpdateResponseDataContactToJson(
    CallLeadUpdateResponseDataContact entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['name'] = entity.name;
  data['email'] = entity.email;
  data['phone'] = entity.phone;
  data['city'] = entity.city;
  data['state'] = entity.state;
  data['country'] = entity.country;
  data['_id'] = entity.id;
  return data;
}

extension CallLeadUpdateResponseDataContactExtension on CallLeadUpdateResponseDataContact {
  CallLeadUpdateResponseDataContact copyWith({
    String? name,
    String? email,
    String? phone,
    String? city,
    String? state,
    String? country,
    String? id,
  }) {
    return CallLeadUpdateResponseDataContact()
      ..name = name ?? this.name
      ..email = email ?? this.email
      ..phone = phone ?? this.phone
      ..city = city ?? this.city
      ..state = state ?? this.state
      ..country = country ?? this.country
      ..id = id ?? this.id;
  }
}

CallLeadUpdateResponseDataLogs $CallLeadUpdateResponseDataLogsFromJson(
    Map<String, dynamic> json) {
  final CallLeadUpdateResponseDataLogs callLeadUpdateResponseDataLogs = CallLeadUpdateResponseDataLogs();
  final String? type = jsonConvert.convert<String>(json['type']);
  if (type != null) {
    callLeadUpdateResponseDataLogs.type = type;
  }
  final String? date = jsonConvert.convert<String>(json['date']);
  if (date != null) {
    callLeadUpdateResponseDataLogs.date = date;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    callLeadUpdateResponseDataLogs.id = id;
  }
  final String? answer = jsonConvert.convert<String>(json['answer']);
  if (answer != null) {
    callLeadUpdateResponseDataLogs.answer = answer;
  }
  final int? duration = jsonConvert.convert<int>(json['duration']);
  if (duration != null) {
    callLeadUpdateResponseDataLogs.duration = duration;
  }
  final String? answertype = jsonConvert.convert<String>(json['answertype']);
  if (answertype != null) {
    callLeadUpdateResponseDataLogs.answertype = answertype;
  }
  return callLeadUpdateResponseDataLogs;
}

Map<String, dynamic> $CallLeadUpdateResponseDataLogsToJson(
    CallLeadUpdateResponseDataLogs entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['type'] = entity.type;
  data['date'] = entity.date;
  data['_id'] = entity.id;
  data['answer'] = entity.answer;
  data['duration'] = entity.duration;
  data['answertype'] = entity.answertype;
  return data;
}

extension CallLeadUpdateResponseDataLogsExtension on CallLeadUpdateResponseDataLogs {
  CallLeadUpdateResponseDataLogs copyWith({
    String? type,
    String? date,
    String? id,
    String? answer,
    int? duration,
    String? answertype,
  }) {
    return CallLeadUpdateResponseDataLogs()
      ..type = type ?? this.type
      ..date = date ?? this.date
      ..id = id ?? this.id
      ..answer = answer ?? this.answer
      ..duration = duration ?? this.duration
      ..answertype = answertype ?? this.answertype;
  }
}