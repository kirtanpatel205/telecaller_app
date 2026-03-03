import 'package:telecaller_app/generated/json/base/json_field.dart';
import 'package:telecaller_app/generated/json/lead_chart_entity.g.dart';
import 'dart:convert';
export 'package:telecaller_app/generated/json/lead_chart_entity.g.dart';

@JsonSerializable()
class LeadChartEntity {
	late bool status;
	late List<LeadChartLeads> leads;
	late List<LeadChartBarChart> barChart;
	late LeadChartPieChart pieChart;

	LeadChartEntity();

	factory LeadChartEntity.fromJson(Map<String, dynamic> json) => $LeadChartEntityFromJson(json);

	Map<String, dynamic> toJson() => $LeadChartEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class LeadChartLeads {
	late String label;
	late int count;

	LeadChartLeads();

	factory LeadChartLeads.fromJson(Map<String, dynamic> json) => $LeadChartLeadsFromJson(json);

	Map<String, dynamic> toJson() => $LeadChartLeadsToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class LeadChartBarChart {
	late String label;
	late int count;

	LeadChartBarChart();

	factory LeadChartBarChart.fromJson(Map<String, dynamic> json) => $LeadChartBarChartFromJson(json);

	Map<String, dynamic> toJson() => $LeadChartBarChartToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class LeadChartPieChart {
	late int completed;
	late int scheduled;
	late int pending;

	LeadChartPieChart();

	factory LeadChartPieChart.fromJson(Map<String, dynamic> json) => $LeadChartPieChartFromJson(json);

	Map<String, dynamic> toJson() => $LeadChartPieChartToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}