import 'package:telecaller_app/generated/json/base/json_convert_content.dart';
import 'package:telecaller_app/core/models/call_chart_entity.dart';

CallChartEntity $CallChartEntityFromJson(Map<String, dynamic> json) {
  final CallChartEntity callChartEntity = CallChartEntity();
  final bool? status = jsonConvert.convert<bool>(json['status']);
  if (status != null) {
    callChartEntity.status = status;
  }
  final List<CallChartBarChart>? barChart = (json['barChart'] as List<dynamic>?)
      ?.map(
          (e) => jsonConvert.convert<CallChartBarChart>(e) as CallChartBarChart)
      .toList();
  if (barChart != null) {
    callChartEntity.barChart = barChart;
  }
  final CallChartPieChart? pieChart = jsonConvert.convert<CallChartPieChart>(
      json['pieChart']);
  if (pieChart != null) {
    callChartEntity.pieChart = pieChart;
  }
  final List<String>? totalSimNumber = (json['totalSimNumber'] as List<
      dynamic>?)?.map(
          (e) => jsonConvert.convert<String>(e) as String).toList();
  if (totalSimNumber != null) {
    callChartEntity.totalSimNumber = totalSimNumber;
  }
  return callChartEntity;
}

Map<String, dynamic> $CallChartEntityToJson(CallChartEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['status'] = entity.status;
  data['barChart'] = entity.barChart.map((v) => v.toJson()).toList();
  data['pieChart'] = entity.pieChart.toJson();
  data['totalSimNumber'] = entity.totalSimNumber;
  return data;
}

extension CallChartEntityExtension on CallChartEntity {
  CallChartEntity copyWith({
    bool? status,
    List<CallChartBarChart>? barChart,
    CallChartPieChart? pieChart,
    List<String>? totalSimNumber,
  }) {
    return CallChartEntity()
      ..status = status ?? this.status
      ..barChart = barChart ?? this.barChart
      ..pieChart = pieChart ?? this.pieChart
      ..totalSimNumber = totalSimNumber ?? this.totalSimNumber;
  }
}

CallChartBarChart $CallChartBarChartFromJson(Map<String, dynamic> json) {
  final CallChartBarChart callChartBarChart = CallChartBarChart();
  final String? label = jsonConvert.convert<String>(json['label']);
  if (label != null) {
    callChartBarChart.label = label;
  }
  final CallChartBarChartIncoming? incoming = jsonConvert.convert<
      CallChartBarChartIncoming>(json['incoming']);
  if (incoming != null) {
    callChartBarChart.incoming = incoming;
  }
  final CallChartBarChartOutgoing? outgoing = jsonConvert.convert<
      CallChartBarChartOutgoing>(json['outgoing']);
  if (outgoing != null) {
    callChartBarChart.outgoing = outgoing;
  }
  return callChartBarChart;
}

Map<String, dynamic> $CallChartBarChartToJson(CallChartBarChart entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['label'] = entity.label;
  data['incoming'] = entity.incoming.toJson();
  data['outgoing'] = entity.outgoing.toJson();
  return data;
}

extension CallChartBarChartExtension on CallChartBarChart {
  CallChartBarChart copyWith({
    String? label,
    CallChartBarChartIncoming? incoming,
    CallChartBarChartOutgoing? outgoing,
  }) {
    return CallChartBarChart()
      ..label = label ?? this.label
      ..incoming = incoming ?? this.incoming
      ..outgoing = outgoing ?? this.outgoing;
  }
}

CallChartBarChartIncoming $CallChartBarChartIncomingFromJson(
    Map<String, dynamic> json) {
  final CallChartBarChartIncoming callChartBarChartIncoming = CallChartBarChartIncoming();
  final int? count = jsonConvert.convert<int>(json['count']);
  if (count != null) {
    callChartBarChartIncoming.count = count;
  }
  final int? totalDuration = jsonConvert.convert<int>(json['totalDuration']);
  if (totalDuration != null) {
    callChartBarChartIncoming.totalDuration = totalDuration;
  }
  return callChartBarChartIncoming;
}

Map<String, dynamic> $CallChartBarChartIncomingToJson(
    CallChartBarChartIncoming entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['count'] = entity.count;
  data['totalDuration'] = entity.totalDuration;
  return data;
}

extension CallChartBarChartIncomingExtension on CallChartBarChartIncoming {
  CallChartBarChartIncoming copyWith({
    int? count,
    int? totalDuration,
  }) {
    return CallChartBarChartIncoming()
      ..count = count ?? this.count
      ..totalDuration = totalDuration ?? this.totalDuration;
  }
}

CallChartBarChartOutgoing $CallChartBarChartOutgoingFromJson(
    Map<String, dynamic> json) {
  final CallChartBarChartOutgoing callChartBarChartOutgoing = CallChartBarChartOutgoing();
  final int? count = jsonConvert.convert<int>(json['count']);
  if (count != null) {
    callChartBarChartOutgoing.count = count;
  }
  final int? totalDuration = jsonConvert.convert<int>(json['totalDuration']);
  if (totalDuration != null) {
    callChartBarChartOutgoing.totalDuration = totalDuration;
  }
  return callChartBarChartOutgoing;
}

Map<String, dynamic> $CallChartBarChartOutgoingToJson(
    CallChartBarChartOutgoing entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['count'] = entity.count;
  data['totalDuration'] = entity.totalDuration;
  return data;
}

extension CallChartBarChartOutgoingExtension on CallChartBarChartOutgoing {
  CallChartBarChartOutgoing copyWith({
    int? count,
    int? totalDuration,
  }) {
    return CallChartBarChartOutgoing()
      ..count = count ?? this.count
      ..totalDuration = totalDuration ?? this.totalDuration;
  }
}

CallChartPieChart $CallChartPieChartFromJson(Map<String, dynamic> json) {
  final CallChartPieChart callChartPieChart = CallChartPieChart();
  final int? incomingCall = jsonConvert.convert<int>(json['incoming_call']);
  if (incomingCall != null) {
    callChartPieChart.incomingCall = incomingCall;
  }
  final int? outgoingCall = jsonConvert.convert<int>(json['outgoing_call']);
  if (outgoingCall != null) {
    callChartPieChart.outgoingCall = outgoingCall;
  }
  final int? missedCall = jsonConvert.convert<int>(json['missed_call']);
  if (missedCall != null) {
    callChartPieChart.missedCall = missedCall;
  }
  final int? notAnsweredCall = jsonConvert.convert<int>(
      json['not_answered_call']);
  if (notAnsweredCall != null) {
    callChartPieChart.notAnsweredCall = notAnsweredCall;
  }
  return callChartPieChart;
}

Map<String, dynamic> $CallChartPieChartToJson(CallChartPieChart entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['incoming_call'] = entity.incomingCall;
  data['outgoing_call'] = entity.outgoingCall;
  data['missed_call'] = entity.missedCall;
  data['not_answered_call'] = entity.notAnsweredCall;
  return data;
}

extension CallChartPieChartExtension on CallChartPieChart {
  CallChartPieChart copyWith({
    int? incomingCall,
    int? outgoingCall,
    int? missedCall,
    int? notAnsweredCall,
  }) {
    return CallChartPieChart()
      ..incomingCall = incomingCall ?? this.incomingCall
      ..outgoingCall = outgoingCall ?? this.outgoingCall
      ..missedCall = missedCall ?? this.missedCall
      ..notAnsweredCall = notAnsweredCall ?? this.notAnsweredCall;
  }
}