import 'package:telecaller_app/generated/json/base/json_field.dart';
import 'package:telecaller_app/generated/json/call_chart_entity.g.dart';
import 'dart:convert';
export 'package:telecaller_app/generated/json/call_chart_entity.g.dart';

@JsonSerializable()
class CallChartEntity {
	late bool status;
	late List<CallChartBarChart> barChart;
	late CallChartPieChart pieChart;
	late List<String> totalSimNumber;

	CallChartEntity();

	factory CallChartEntity.fromJson(Map<String, dynamic> json) => $CallChartEntityFromJson(json);

	Map<String, dynamic> toJson() => $CallChartEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class CallChartBarChart {
	late String label;
	late CallChartBarChartIncoming incoming;
	late CallChartBarChartOutgoing outgoing;

	CallChartBarChart();

	factory CallChartBarChart.fromJson(Map<String, dynamic> json) => $CallChartBarChartFromJson(json);

	Map<String, dynamic> toJson() => $CallChartBarChartToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class CallChartBarChartIncoming {
	late int count;
	late int totalDuration;

	CallChartBarChartIncoming();

	factory CallChartBarChartIncoming.fromJson(Map<String, dynamic> json) => $CallChartBarChartIncomingFromJson(json);

	Map<String, dynamic> toJson() => $CallChartBarChartIncomingToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class CallChartBarChartOutgoing {
	late int count;
	late int totalDuration;

	CallChartBarChartOutgoing();

	factory CallChartBarChartOutgoing.fromJson(Map<String, dynamic> json) => $CallChartBarChartOutgoingFromJson(json);

	Map<String, dynamic> toJson() => $CallChartBarChartOutgoingToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class CallChartPieChart {
	@JSONField(name: 'incoming_call')
	late int incomingCall;
	@JSONField(name: 'outgoing_call')
	late int outgoingCall;
	@JSONField(name: 'missed_call')
	late int missedCall;
	@JSONField(name: 'not_answered_call')
	late int notAnsweredCall;

	CallChartPieChart();

	factory CallChartPieChart.fromJson(Map<String, dynamic> json) => $CallChartPieChartFromJson(json);

	Map<String, dynamic> toJson() => $CallChartPieChartToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}