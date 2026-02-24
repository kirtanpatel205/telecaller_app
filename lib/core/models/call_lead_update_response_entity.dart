import 'package:telecaller_app/generated/json/base/json_field.dart';
import 'package:telecaller_app/generated/json/call_lead_update_response_entity.g.dart';
import 'dart:convert';
export 'package:telecaller_app/generated/json/call_lead_update_response_entity.g.dart';

@JsonSerializable()
class CallLeadUpdateResponseEntity {
	bool? status = false;
	CallLeadUpdateResponseData? data;

	CallLeadUpdateResponseEntity();

	factory CallLeadUpdateResponseEntity.fromJson(Map<String, dynamic> json) => $CallLeadUpdateResponseEntityFromJson(json);

	Map<String, dynamic> toJson() => $CallLeadUpdateResponseEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class CallLeadUpdateResponseData {
	@JSONField(name: '_id')
	String? id = '';
	String? leadId = '';
	String? userId = '';
	String? panelId = '';
	String? assignedTo = '';
	String? status = '';
	String? scheduleAt = '';
	CallLeadUpdateResponseDataContact? contact;
	List<CallLeadUpdateResponseDataLogs>? logs = [];
	@JSONField(name: '__v')
	int? v = 0;
	String? createdAt = '';
	String? updatedAt = '';

	CallLeadUpdateResponseData();

	factory CallLeadUpdateResponseData.fromJson(Map<String, dynamic> json) => $CallLeadUpdateResponseDataFromJson(json);

	Map<String, dynamic> toJson() => $CallLeadUpdateResponseDataToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class CallLeadUpdateResponseDataContact {
	String? name = '';
	String? email = '';
	String? phone = '';
	String? city = '';
	String? state = '';
	String? country = '';
	@JSONField(name: '_id')
	String? id = '';

	CallLeadUpdateResponseDataContact();

	factory CallLeadUpdateResponseDataContact.fromJson(Map<String, dynamic> json) => $CallLeadUpdateResponseDataContactFromJson(json);

	Map<String, dynamic> toJson() => $CallLeadUpdateResponseDataContactToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class CallLeadUpdateResponseDataLogs {
	String? type = '';
	String? date = '';
	@JSONField(name: '_id')
	String? id = '';
	String? answer = '';
	int? duration = 0;
	String? answertype = '';

	CallLeadUpdateResponseDataLogs();

	factory CallLeadUpdateResponseDataLogs.fromJson(Map<String, dynamic> json) => $CallLeadUpdateResponseDataLogsFromJson(json);

	Map<String, dynamic> toJson() => $CallLeadUpdateResponseDataLogsToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}