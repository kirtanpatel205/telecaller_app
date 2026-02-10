import 'package:telecaller_app/generated/json/base/json_field.dart';
import 'package:telecaller_app/generated/json/all_lead_entity.g.dart';
import 'dart:convert';
export 'package:telecaller_app/generated/json/all_lead_entity.g.dart';

@JsonSerializable()
class AllLeadEntity {
	bool? status = false;
	int? total = 0;
	@JSONField(name: 'Leads')
	List<AllLeadLeads>? leads = [];

	AllLeadEntity();

	factory AllLeadEntity.fromJson(Map<String, dynamic> json) => $AllLeadEntityFromJson(json);

	Map<String, dynamic> toJson() => $AllLeadEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class AllLeadLeads {
	@JSONField(name: '_id')
	String? id = '';
	String? name = '';
	String? status = '';
	String? userId = '';
	String? panelId = '';
	List<AllLeadLeadsAllot>? allot = [];
	AllLeadLeadsSchedule? schedule;
	String? createdAt = '';
	String? updatedAt = '';
	@JSONField(name: '__v')
	int? v = 0;
	AllLeadLeadsFormId? formId;
	AllLeadLeads();

	factory AllLeadLeads.fromJson(Map<String, dynamic> json) => $AllLeadLeadsFromJson(json);

	Map<String, dynamic> toJson() => $AllLeadLeadsToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class AllLeadLeadsAllot {
	AllLeadLeadsAllotUserId? userId;
	int? value = 0;
	@JSONField(name: '_id')
	String? id = '';

	AllLeadLeadsAllot();

	factory AllLeadLeadsAllot.fromJson(Map<String, dynamic> json) => $AllLeadLeadsAllotFromJson(json);

	Map<String, dynamic> toJson() => $AllLeadLeadsAllotToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class AllLeadLeadsAllotUserId {
	@JSONField(name: '_id')
	String? id = '';
	String? name = '';
	String? phone = '';
	String? profile = '';
	String? email = '';

	AllLeadLeadsAllotUserId();

	factory AllLeadLeadsAllotUserId.fromJson(Map<String, dynamic> json) => $AllLeadLeadsAllotUserIdFromJson(json);

	Map<String, dynamic> toJson() => $AllLeadLeadsAllotUserIdToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class AllLeadLeadsSchedule {
	String? type = '';
	String? startDate = '';
	String? endDate = '';
	@JSONField(name: '_id')
	String? id = '';

	AllLeadLeadsSchedule();

	factory AllLeadLeadsSchedule.fromJson(Map<String, dynamic> json) => $AllLeadLeadsScheduleFromJson(json);

	Map<String, dynamic> toJson() => $AllLeadLeadsScheduleToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class AllLeadLeadsFormId {
	@JSONField(name: '_id')
	String? id = '';
	String? title = '';
	String? description = '';
	List<AllLeadLeadsFormIdFields>? fields = [];
	String? userId = '';
	String? panelId = '';
	String? createdAt = '';
	String? updatedAt = '';
	@JSONField(name: '__v')
	int? v = 0;

	AllLeadLeadsFormId();

	factory AllLeadLeadsFormId.fromJson(Map<String, dynamic> json) => $AllLeadLeadsFormIdFromJson(json);

	Map<String, dynamic> toJson() => $AllLeadLeadsFormIdToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class AllLeadLeadsFormIdFields {
	String? type = '';
	String? label = '';
	String? placeholder = '';
	bool? required = false;
	@JSONField(name: '_id')
	String? id = '';
	List<String>? options = [];

	AllLeadLeadsFormIdFields();

	factory AllLeadLeadsFormIdFields.fromJson(Map<String, dynamic> json) => $AllLeadLeadsFormIdFieldsFromJson(json);

	Map<String, dynamic> toJson() => $AllLeadLeadsFormIdFieldsToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}