import 'package:telecaller_app/generated/json/base/json_convert_content.dart';
import 'package:telecaller_app/core/models/lead_contact_id_entity.dart';

LeadContactIdEntity $LeadContactIdEntityFromJson(Map<String, dynamic> json) {
  final LeadContactIdEntity leadContactIdEntity = LeadContactIdEntity();
  final bool? status = jsonConvert.convert<bool>(json['status']);
  if (status != null) {
    leadContactIdEntity.status = status;
  }
  final int? total = jsonConvert.convert<int>(json['total']);
  if (total != null) {
    leadContactIdEntity.total = total;
  }
  final List<
      LeadContactIdLeadContacts>? leadContacts = (json['lead_contacts'] as List<
      dynamic>?)?.map(
          (e) =>
      jsonConvert.convert<LeadContactIdLeadContacts>(
          e) as LeadContactIdLeadContacts).toList();
  if (leadContacts != null) {
    leadContactIdEntity.leadContacts = leadContacts;
  }
  return leadContactIdEntity;
}

Map<String, dynamic> $LeadContactIdEntityToJson(LeadContactIdEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['status'] = entity.status;
  data['total'] = entity.total;
  data['lead_contacts'] = entity.leadContacts?.map((v) => v.toJson()).toList();
  return data;
}

extension LeadContactIdEntityExtension on LeadContactIdEntity {
  LeadContactIdEntity copyWith({
    bool? status,
    int? total,
    List<LeadContactIdLeadContacts>? leadContacts,
  }) {
    return LeadContactIdEntity()
      ..status = status ?? this.status
      ..total = total ?? this.total
      ..leadContacts = leadContacts ?? this.leadContacts;
  }
}

LeadContactIdLeadContacts $LeadContactIdLeadContactsFromJson(
    Map<String, dynamic> json) {
  final LeadContactIdLeadContacts leadContactIdLeadContacts = LeadContactIdLeadContacts();
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    leadContactIdLeadContacts.id = id;
  }
  final String? leadId = jsonConvert.convert<String>(json['leadId']);
  if (leadId != null) {
    leadContactIdLeadContacts.leadId = leadId;
  }
  final String? userId = jsonConvert.convert<String>(json['userId']);
  if (userId != null) {
    leadContactIdLeadContacts.userId = userId;
  }
  final String? panelId = jsonConvert.convert<String>(json['panelId']);
  if (panelId != null) {
    leadContactIdLeadContacts.panelId = panelId;
  }
  final LeadContactIdLeadContactsAssignedTo? assignedTo = jsonConvert.convert<
      LeadContactIdLeadContactsAssignedTo>(json['assignedTo']);
  if (assignedTo != null) {
    leadContactIdLeadContacts.assignedTo = assignedTo;
  }
  final String? status = jsonConvert.convert<String>(json['status']);
  if (status != null) {
    leadContactIdLeadContacts.status = status;
  }
  final String? scheduleAt = jsonConvert.convert<String>(json['scheduleAt']);
  if (scheduleAt != null) {
    leadContactIdLeadContacts.scheduleAt = scheduleAt;
  }
  final LeadContactIdLeadContactsContact? contact = jsonConvert.convert<
      LeadContactIdLeadContactsContact>(json['contact']);
  if (contact != null) {
    leadContactIdLeadContacts.contact = contact;
  }
  final List<LeadContactIdLeadContactsLogs>? logs = (json['logs'] as List<
      dynamic>?)?.map(
          (e) =>
      jsonConvert.convert<LeadContactIdLeadContactsLogs>(
          e) as LeadContactIdLeadContactsLogs).toList();
  if (logs != null) {
    leadContactIdLeadContacts.logs = logs;
  }
  final int? v = jsonConvert.convert<int>(json['__v']);
  if (v != null) {
    leadContactIdLeadContacts.v = v;
  }
  final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
  if (createdAt != null) {
    leadContactIdLeadContacts.createdAt = createdAt;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
  if (updatedAt != null) {
    leadContactIdLeadContacts.updatedAt = updatedAt;
  }
  return leadContactIdLeadContacts;
}

Map<String, dynamic> $LeadContactIdLeadContactsToJson(
    LeadContactIdLeadContacts entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['_id'] = entity.id;
  data['leadId'] = entity.leadId;
  data['userId'] = entity.userId;
  data['panelId'] = entity.panelId;
  data['assignedTo'] = entity.assignedTo?.toJson();
  data['status'] = entity.status;
  data['scheduleAt'] = entity.scheduleAt;
  data['contact'] = entity.contact?.toJson();
  data['logs'] = entity.logs?.map((v) => v.toJson()).toList();
  data['__v'] = entity.v;
  data['createdAt'] = entity.createdAt;
  data['updatedAt'] = entity.updatedAt;
  return data;
}

extension LeadContactIdLeadContactsExtension on LeadContactIdLeadContacts {
  LeadContactIdLeadContacts copyWith({
    String? id,
    String? leadId,
    String? userId,
    String? panelId,
    LeadContactIdLeadContactsAssignedTo? assignedTo,
    String? status,
    String? scheduleAt,
    LeadContactIdLeadContactsContact? contact,
    List<LeadContactIdLeadContactsLogs>? logs,
    int? v,
    String? createdAt,
    String? updatedAt,
  }) {
    return LeadContactIdLeadContacts()
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

LeadContactIdLeadContactsAssignedTo $LeadContactIdLeadContactsAssignedToFromJson(
    Map<String, dynamic> json) {
  final LeadContactIdLeadContactsAssignedTo leadContactIdLeadContactsAssignedTo = LeadContactIdLeadContactsAssignedTo();
  final LeadContactIdLeadContactsAssignedToAddress? address = jsonConvert
      .convert<LeadContactIdLeadContactsAssignedToAddress>(json['address']);
  if (address != null) {
    leadContactIdLeadContactsAssignedTo.address = address;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    leadContactIdLeadContactsAssignedTo.id = id;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    leadContactIdLeadContactsAssignedTo.name = name;
  }
  final String? phone = jsonConvert.convert<String>(json['phone']);
  if (phone != null) {
    leadContactIdLeadContactsAssignedTo.phone = phone;
  }
  final String? email = jsonConvert.convert<String>(json['email']);
  if (email != null) {
    leadContactIdLeadContactsAssignedTo.email = email;
  }
  return leadContactIdLeadContactsAssignedTo;
}

Map<String, dynamic> $LeadContactIdLeadContactsAssignedToToJson(
    LeadContactIdLeadContactsAssignedTo entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['address'] = entity.address?.toJson();
  data['_id'] = entity.id;
  data['name'] = entity.name;
  data['phone'] = entity.phone;
  data['email'] = entity.email;
  return data;
}

extension LeadContactIdLeadContactsAssignedToExtension on LeadContactIdLeadContactsAssignedTo {
  LeadContactIdLeadContactsAssignedTo copyWith({
    LeadContactIdLeadContactsAssignedToAddress? address,
    String? id,
    String? name,
    String? phone,
    String? email,
  }) {
    return LeadContactIdLeadContactsAssignedTo()
      ..address = address ?? this.address
      ..id = id ?? this.id
      ..name = name ?? this.name
      ..phone = phone ?? this.phone
      ..email = email ?? this.email;
  }
}

LeadContactIdLeadContactsAssignedToAddress $LeadContactIdLeadContactsAssignedToAddressFromJson(
    Map<String, dynamic> json) {
  final LeadContactIdLeadContactsAssignedToAddress leadContactIdLeadContactsAssignedToAddress = LeadContactIdLeadContactsAssignedToAddress();
  final String? addressLine1 = jsonConvert.convert<String>(
      json['addressLine1']);
  if (addressLine1 != null) {
    leadContactIdLeadContactsAssignedToAddress.addressLine1 = addressLine1;
  }
  final String? addressLine2 = jsonConvert.convert<String>(
      json['addressLine2']);
  if (addressLine2 != null) {
    leadContactIdLeadContactsAssignedToAddress.addressLine2 = addressLine2;
  }
  final String? city = jsonConvert.convert<String>(json['city']);
  if (city != null) {
    leadContactIdLeadContactsAssignedToAddress.city = city;
  }
  final String? state = jsonConvert.convert<String>(json['state']);
  if (state != null) {
    leadContactIdLeadContactsAssignedToAddress.state = state;
  }
  final String? zip = jsonConvert.convert<String>(json['zip']);
  if (zip != null) {
    leadContactIdLeadContactsAssignedToAddress.zip = zip;
  }
  final String? country = jsonConvert.convert<String>(json['country']);
  if (country != null) {
    leadContactIdLeadContactsAssignedToAddress.country = country;
  }
  final String? type = jsonConvert.convert<String>(json['type']);
  if (type != null) {
    leadContactIdLeadContactsAssignedToAddress.type = type;
  }
  return leadContactIdLeadContactsAssignedToAddress;
}

Map<String, dynamic> $LeadContactIdLeadContactsAssignedToAddressToJson(
    LeadContactIdLeadContactsAssignedToAddress entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['addressLine1'] = entity.addressLine1;
  data['addressLine2'] = entity.addressLine2;
  data['city'] = entity.city;
  data['state'] = entity.state;
  data['zip'] = entity.zip;
  data['country'] = entity.country;
  data['type'] = entity.type;
  return data;
}

extension LeadContactIdLeadContactsAssignedToAddressExtension on LeadContactIdLeadContactsAssignedToAddress {
  LeadContactIdLeadContactsAssignedToAddress copyWith({
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? zip,
    String? country,
    String? type,
  }) {
    return LeadContactIdLeadContactsAssignedToAddress()
      ..addressLine1 = addressLine1 ?? this.addressLine1
      ..addressLine2 = addressLine2 ?? this.addressLine2
      ..city = city ?? this.city
      ..state = state ?? this.state
      ..zip = zip ?? this.zip
      ..country = country ?? this.country
      ..type = type ?? this.type;
  }
}

LeadContactIdLeadContactsContact $LeadContactIdLeadContactsContactFromJson(
    Map<String, dynamic> json) {
  final LeadContactIdLeadContactsContact leadContactIdLeadContactsContact = LeadContactIdLeadContactsContact();
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    leadContactIdLeadContactsContact.name = name;
  }
  final String? email = jsonConvert.convert<String>(json['email']);
  if (email != null) {
    leadContactIdLeadContactsContact.email = email;
  }
  final String? phone = jsonConvert.convert<String>(json['phone']);
  if (phone != null) {
    leadContactIdLeadContactsContact.phone = phone;
  }
  final String? city = jsonConvert.convert<String>(json['city']);
  if (city != null) {
    leadContactIdLeadContactsContact.city = city;
  }
  final String? state = jsonConvert.convert<String>(json['state']);
  if (state != null) {
    leadContactIdLeadContactsContact.state = state;
  }
  final String? country = jsonConvert.convert<String>(json['country']);
  if (country != null) {
    leadContactIdLeadContactsContact.country = country;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    leadContactIdLeadContactsContact.id = id;
  }
  return leadContactIdLeadContactsContact;
}

Map<String, dynamic> $LeadContactIdLeadContactsContactToJson(
    LeadContactIdLeadContactsContact entity) {
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

extension LeadContactIdLeadContactsContactExtension on LeadContactIdLeadContactsContact {
  LeadContactIdLeadContactsContact copyWith({
    String? name,
    String? email,
    String? phone,
    String? city,
    String? state,
    String? country,
    String? id,
  }) {
    return LeadContactIdLeadContactsContact()
      ..name = name ?? this.name
      ..email = email ?? this.email
      ..phone = phone ?? this.phone
      ..city = city ?? this.city
      ..state = state ?? this.state
      ..country = country ?? this.country
      ..id = id ?? this.id;
  }
}

LeadContactIdLeadContactsLogs $LeadContactIdLeadContactsLogsFromJson(
    Map<String, dynamic> json) {
  final LeadContactIdLeadContactsLogs leadContactIdLeadContactsLogs = LeadContactIdLeadContactsLogs();
  final String? type = jsonConvert.convert<String>(json['type']);
  if (type != null) {
    leadContactIdLeadContactsLogs.type = type;
  }
  final String? date = jsonConvert.convert<String>(json['date']);
  if (date != null) {
    leadContactIdLeadContactsLogs.date = date;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    leadContactIdLeadContactsLogs.id = id;
  }
  final String? answer = jsonConvert.convert<String>(json['answer']);
  if (answer != null) {
    leadContactIdLeadContactsLogs.answer = answer;
  }
  final int? duration = jsonConvert.convert<int>(json['duration']);
  if (duration != null) {
    leadContactIdLeadContactsLogs.duration = duration;
  }
  return leadContactIdLeadContactsLogs;
}

Map<String, dynamic> $LeadContactIdLeadContactsLogsToJson(
    LeadContactIdLeadContactsLogs entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['type'] = entity.type;
  data['date'] = entity.date;
  data['_id'] = entity.id;
  data['answer'] = entity.answer;
  data['duration'] = entity.duration;
  return data;
}

extension LeadContactIdLeadContactsLogsExtension on LeadContactIdLeadContactsLogs {
  LeadContactIdLeadContactsLogs copyWith({
    String? type,
    String? date,
    String? id,
    String? answer,
    int? duration,
  }) {
    return LeadContactIdLeadContactsLogs()
      ..type = type ?? this.type
      ..date = date ?? this.date
      ..id = id ?? this.id
      ..answer = answer ?? this.answer
      ..duration = duration ?? this.duration;
  }
}