import 'package:telecaller_app/generated/json/base/json_field.dart';
import 'package:telecaller_app/generated/json/get_static_entity.g.dart';
import 'dart:convert';
export 'package:telecaller_app/generated/json/get_static_entity.g.dart';

@JsonSerializable()
class GetStaticEntity {
	late bool status;
	late GetStaticStatistics statistics;

	GetStaticEntity();

	factory GetStaticEntity.fromJson(Map<String, dynamic> json) => $GetStaticEntityFromJson(json);

	Map<String, dynamic> toJson() => $GetStaticEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class GetStaticStatistics {
	late int totalLeads;
	late int todayLeads;
	late int totalFormSubmitted;
	late int todayFormSubmitted;
	late int totalLeadContacts;
	late int todayLeadContacts;
	late int scheduledTotal;
	late int scheduledToday;
	late int completedTotal;
	late int completedToday;
	late int pendingTotal;
	late int pendingToday;
	late int incomingTotal;
	late int incomingToday;
	late int outgoingTotal;
	late int outgoingToday;
	late int missedTotal;
	late int missedToday;
	late int notAnsweredTotal;
	late int notAnsweredToday;

	GetStaticStatistics();

	factory GetStaticStatistics.fromJson(Map<String, dynamic> json) => $GetStaticStatisticsFromJson(json);

	Map<String, dynamic> toJson() => $GetStaticStatisticsToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}