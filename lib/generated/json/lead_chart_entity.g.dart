import 'package:telecaller_app/generated/json/base/json_convert_content.dart';
import 'package:telecaller_app/core/models/lead_chart_entity.dart';

LeadChartEntity $LeadChartEntityFromJson(Map<String, dynamic> json) {
  final LeadChartEntity leadChartEntity = LeadChartEntity();
  final bool? status = jsonConvert.convert<bool>(json['status']);
  if (status != null) {
    leadChartEntity.status = status;
  }
  final List<LeadChartLeads>? leads = (json['leads'] as List<dynamic>?)
      ?.map(
          (e) => jsonConvert.convert<LeadChartLeads>(e) as LeadChartLeads)
      .toList();
  if (leads != null) {
    leadChartEntity.leads = leads;
  }
  final List<LeadChartBarChart>? barChart = (json['barChart'] as List<dynamic>?)
      ?.map(
          (e) => jsonConvert.convert<LeadChartBarChart>(e) as LeadChartBarChart)
      .toList();
  if (barChart != null) {
    leadChartEntity.barChart = barChart;
  }
  final LeadChartPieChart? pieChart = jsonConvert.convert<LeadChartPieChart>(
      json['pieChart']);
  if (pieChart != null) {
    leadChartEntity.pieChart = pieChart;
  }
  return leadChartEntity;
}

Map<String, dynamic> $LeadChartEntityToJson(LeadChartEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['status'] = entity.status;
  data['leads'] = entity.leads.map((v) => v.toJson()).toList();
  data['barChart'] = entity.barChart.map((v) => v.toJson()).toList();
  data['pieChart'] = entity.pieChart.toJson();
  return data;
}

extension LeadChartEntityExtension on LeadChartEntity {
  LeadChartEntity copyWith({
    bool? status,
    List<LeadChartLeads>? leads,
    List<LeadChartBarChart>? barChart,
    LeadChartPieChart? pieChart,
  }) {
    return LeadChartEntity()
      ..status = status ?? this.status
      ..leads = leads ?? this.leads
      ..barChart = barChart ?? this.barChart
      ..pieChart = pieChart ?? this.pieChart;
  }
}

LeadChartLeads $LeadChartLeadsFromJson(Map<String, dynamic> json) {
  final LeadChartLeads leadChartLeads = LeadChartLeads();
  final String? label = jsonConvert.convert<String>(json['label']);
  if (label != null) {
    leadChartLeads.label = label;
  }
  final int? count = jsonConvert.convert<int>(json['count']);
  if (count != null) {
    leadChartLeads.count = count;
  }
  return leadChartLeads;
}

Map<String, dynamic> $LeadChartLeadsToJson(LeadChartLeads entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['label'] = entity.label;
  data['count'] = entity.count;
  return data;
}

extension LeadChartLeadsExtension on LeadChartLeads {
  LeadChartLeads copyWith({
    String? label,
    int? count,
  }) {
    return LeadChartLeads()
      ..label = label ?? this.label
      ..count = count ?? this.count;
  }
}

LeadChartBarChart $LeadChartBarChartFromJson(Map<String, dynamic> json) {
  final LeadChartBarChart leadChartBarChart = LeadChartBarChart();
  final String? label = jsonConvert.convert<String>(json['label']);
  if (label != null) {
    leadChartBarChart.label = label;
  }
  final int? count = jsonConvert.convert<int>(json['count']);
  if (count != null) {
    leadChartBarChart.count = count;
  }
  return leadChartBarChart;
}

Map<String, dynamic> $LeadChartBarChartToJson(LeadChartBarChart entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['label'] = entity.label;
  data['count'] = entity.count;
  return data;
}

extension LeadChartBarChartExtension on LeadChartBarChart {
  LeadChartBarChart copyWith({
    String? label,
    int? count,
  }) {
    return LeadChartBarChart()
      ..label = label ?? this.label
      ..count = count ?? this.count;
  }
}

LeadChartPieChart $LeadChartPieChartFromJson(Map<String, dynamic> json) {
  final LeadChartPieChart leadChartPieChart = LeadChartPieChart();
  final int? completed = jsonConvert.convert<int>(json['completed']);
  if (completed != null) {
    leadChartPieChart.completed = completed;
  }
  final int? scheduled = jsonConvert.convert<int>(json['scheduled']);
  if (scheduled != null) {
    leadChartPieChart.scheduled = scheduled;
  }
  final int? pending = jsonConvert.convert<int>(json['pending']);
  if (pending != null) {
    leadChartPieChart.pending = pending;
  }
  return leadChartPieChart;
}

Map<String, dynamic> $LeadChartPieChartToJson(LeadChartPieChart entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['completed'] = entity.completed;
  data['scheduled'] = entity.scheduled;
  data['pending'] = entity.pending;
  return data;
}

extension LeadChartPieChartExtension on LeadChartPieChart {
  LeadChartPieChart copyWith({
    int? completed,
    int? scheduled,
    int? pending,
  }) {
    return LeadChartPieChart()
      ..completed = completed ?? this.completed
      ..scheduled = scheduled ?? this.scheduled
      ..pending = pending ?? this.pending;
  }
}