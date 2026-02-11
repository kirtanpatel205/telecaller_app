import 'package:telecaller_app/generated/json/base/json_field.dart';
import 'package:telecaller_app/generated/json/lead_contact_id_entity.g.dart';
import 'dart:convert';
export 'package:telecaller_app/generated/json/lead_contact_id_entity.g.dart';

@JsonSerializable()
class LeadContactIdEntity {
	bool? status = false;
	int? total = 0;
	@JSONField(name: 'lead_contacts')
	List<LeadContactIdLeadContacts>? leadContacts = [];

	LeadContactIdEntity();

	factory LeadContactIdEntity.fromJson(Map<String, dynamic> json) => $LeadContactIdEntityFromJson(json);

	Map<String, dynamic> toJson() => $LeadContactIdEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class LeadContactIdLeadContacts {
	@JSONField(name: '_id')
	String? id = '';
	String? leadId = '';
	String? userId = '';
	String? panelId = '';
	LeadContactIdLeadContactsAssignedTo? assignedTo;
	String? status = '';
	String? scheduleAt = '';
	LeadContactIdLeadContactsContact? contact;
	List<LeadContactIdLeadContactsLogs>? logs = [];
	@JSONField(name: '__v')
	int? v = 0;
	String? createdAt = '';
	String? updatedAt = '';

	LeadContactIdLeadContacts();

	factory LeadContactIdLeadContacts.fromJson(Map<String, dynamic> json) => $LeadContactIdLeadContactsFromJson(json);

	Map<String, dynamic> toJson() => $LeadContactIdLeadContactsToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class LeadContactIdLeadContactsAssignedTo {
	LeadContactIdLeadContactsAssignedToAddress? address;
	@JSONField(name: '_id')
	String? id = '';
	String? name = '';
	String? phone = '';
	String? email = '';

	LeadContactIdLeadContactsAssignedTo();

	factory LeadContactIdLeadContactsAssignedTo.fromJson(Map<String, dynamic> json) => $LeadContactIdLeadContactsAssignedToFromJson(json);

	Map<String, dynamic> toJson() => $LeadContactIdLeadContactsAssignedToToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class LeadContactIdLeadContactsAssignedToAddress {
	String? addressLine1 = '';
	String? addressLine2 = '';
	String? city = '';
	String? state = '';
	String? zip = '';
	String? country = '';
	String? type = '';

	LeadContactIdLeadContactsAssignedToAddress();

	factory LeadContactIdLeadContactsAssignedToAddress.fromJson(Map<String, dynamic> json) => $LeadContactIdLeadContactsAssignedToAddressFromJson(json);

	Map<String, dynamic> toJson() => $LeadContactIdLeadContactsAssignedToAddressToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class LeadContactIdLeadContactsContact {
	String? name = '';
	String? email = '';
	String? phone = '';
	String? city = '';
	String? state = '';
	String? country = '';
	@JSONField(name: '_id')
	String? id = '';

	LeadContactIdLeadContactsContact();

	factory LeadContactIdLeadContactsContact.fromJson(Map<String, dynamic> json) => $LeadContactIdLeadContactsContactFromJson(json);

	Map<String, dynamic> toJson() => $LeadContactIdLeadContactsContactToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class LeadContactIdLeadContactsLogs {
	String? type = '';
	String? date = '';
	@JSONField(name: '_id')
	String? id = '';
	String? answer = '';
	int? duration = 0;

	LeadContactIdLeadContactsLogs();

	factory LeadContactIdLeadContactsLogs.fromJson(Map<String, dynamic> json) => $LeadContactIdLeadContactsLogsFromJson(json);

	Map<String, dynamic> toJson() => $LeadContactIdLeadContactsLogsToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}