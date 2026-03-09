import 'package:telecaller_app/generated/json/base/json_convert_content.dart';
import 'package:telecaller_app/core/models/get_static_entity.dart';

GetStaticEntity $GetStaticEntityFromJson(Map<String, dynamic> json) {
  final GetStaticEntity getStaticEntity = GetStaticEntity();
  final bool? status = jsonConvert.convert<bool>(json['status']);
  if (status != null) {
    getStaticEntity.status = status;
  }
  final GetStaticStatistics? statistics = jsonConvert.convert<
      GetStaticStatistics>(json['statistics']);
  if (statistics != null) {
    getStaticEntity.statistics = statistics;
  }
  return getStaticEntity;
}

Map<String, dynamic> $GetStaticEntityToJson(GetStaticEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['status'] = entity.status;
  data['statistics'] = entity.statistics.toJson();
  return data;
}

extension GetStaticEntityExtension on GetStaticEntity {
  GetStaticEntity copyWith({
    bool? status,
    GetStaticStatistics? statistics,
  }) {
    return GetStaticEntity()
      ..status = status ?? this.status
      ..statistics = statistics ?? this.statistics;
  }
}

GetStaticStatistics $GetStaticStatisticsFromJson(Map<String, dynamic> json) {
  final GetStaticStatistics getStaticStatistics = GetStaticStatistics();
  final int? totalLeads = jsonConvert.convert<int>(json['totalLeads']);
  if (totalLeads != null) {
    getStaticStatistics.totalLeads = totalLeads;
  }
  final int? todayLeads = jsonConvert.convert<int>(json['todayLeads']);
  if (todayLeads != null) {
    getStaticStatistics.todayLeads = todayLeads;
  }
  final int? totalFormSubmitted = jsonConvert.convert<int>(
      json['totalFormSubmitted']);
  if (totalFormSubmitted != null) {
    getStaticStatistics.totalFormSubmitted = totalFormSubmitted;
  }
  final int? todayFormSubmitted = jsonConvert.convert<int>(
      json['todayFormSubmitted']);
  if (todayFormSubmitted != null) {
    getStaticStatistics.todayFormSubmitted = todayFormSubmitted;
  }
  final int? totalLeadContacts = jsonConvert.convert<int>(
      json['totalLeadContacts']);
  if (totalLeadContacts != null) {
    getStaticStatistics.totalLeadContacts = totalLeadContacts;
  }
  final int? todayLeadContacts = jsonConvert.convert<int>(
      json['todayLeadContacts']);
  if (todayLeadContacts != null) {
    getStaticStatistics.todayLeadContacts = todayLeadContacts;
  }
  final int? scheduledTotal = jsonConvert.convert<int>(json['scheduledTotal']);
  if (scheduledTotal != null) {
    getStaticStatistics.scheduledTotal = scheduledTotal;
  }
  final int? scheduledToday = jsonConvert.convert<int>(json['scheduledToday']);
  if (scheduledToday != null) {
    getStaticStatistics.scheduledToday = scheduledToday;
  }
  final int? completedTotal = jsonConvert.convert<int>(json['completedTotal']);
  if (completedTotal != null) {
    getStaticStatistics.completedTotal = completedTotal;
  }
  final int? completedToday = jsonConvert.convert<int>(json['completedToday']);
  if (completedToday != null) {
    getStaticStatistics.completedToday = completedToday;
  }
  final int? pendingTotal = jsonConvert.convert<int>(json['pendingTotal']);
  if (pendingTotal != null) {
    getStaticStatistics.pendingTotal = pendingTotal;
  }
  final int? pendingToday = jsonConvert.convert<int>(json['pendingToday']);
  if (pendingToday != null) {
    getStaticStatistics.pendingToday = pendingToday;
  }
  final int? incomingTotal = jsonConvert.convert<int>(json['incomingTotal']);
  if (incomingTotal != null) {
    getStaticStatistics.incomingTotal = incomingTotal;
  }
  final int? incomingToday = jsonConvert.convert<int>(json['incomingToday']);
  if (incomingToday != null) {
    getStaticStatistics.incomingToday = incomingToday;
  }
  final int? outgoingTotal = jsonConvert.convert<int>(json['outgoingTotal']);
  if (outgoingTotal != null) {
    getStaticStatistics.outgoingTotal = outgoingTotal;
  }
  final int? outgoingToday = jsonConvert.convert<int>(json['outgoingToday']);
  if (outgoingToday != null) {
    getStaticStatistics.outgoingToday = outgoingToday;
  }
  final int? missedTotal = jsonConvert.convert<int>(json['missedTotal']);
  if (missedTotal != null) {
    getStaticStatistics.missedTotal = missedTotal;
  }
  final int? missedToday = jsonConvert.convert<int>(json['missedToday']);
  if (missedToday != null) {
    getStaticStatistics.missedToday = missedToday;
  }
  final int? notAnsweredTotal = jsonConvert.convert<int>(
      json['notAnsweredTotal']);
  if (notAnsweredTotal != null) {
    getStaticStatistics.notAnsweredTotal = notAnsweredTotal;
  }
  final int? notAnsweredToday = jsonConvert.convert<int>(
      json['notAnsweredToday']);
  if (notAnsweredToday != null) {
    getStaticStatistics.notAnsweredToday = notAnsweredToday;
  }
  return getStaticStatistics;
}

Map<String, dynamic> $GetStaticStatisticsToJson(GetStaticStatistics entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['totalLeads'] = entity.totalLeads;
  data['todayLeads'] = entity.todayLeads;
  data['totalFormSubmitted'] = entity.totalFormSubmitted;
  data['todayFormSubmitted'] = entity.todayFormSubmitted;
  data['totalLeadContacts'] = entity.totalLeadContacts;
  data['todayLeadContacts'] = entity.todayLeadContacts;
  data['scheduledTotal'] = entity.scheduledTotal;
  data['scheduledToday'] = entity.scheduledToday;
  data['completedTotal'] = entity.completedTotal;
  data['completedToday'] = entity.completedToday;
  data['pendingTotal'] = entity.pendingTotal;
  data['pendingToday'] = entity.pendingToday;
  data['incomingTotal'] = entity.incomingTotal;
  data['incomingToday'] = entity.incomingToday;
  data['outgoingTotal'] = entity.outgoingTotal;
  data['outgoingToday'] = entity.outgoingToday;
  data['missedTotal'] = entity.missedTotal;
  data['missedToday'] = entity.missedToday;
  data['notAnsweredTotal'] = entity.notAnsweredTotal;
  data['notAnsweredToday'] = entity.notAnsweredToday;
  return data;
}

extension GetStaticStatisticsExtension on GetStaticStatistics {
  GetStaticStatistics copyWith({
    int? totalLeads,
    int? todayLeads,
    int? totalFormSubmitted,
    int? todayFormSubmitted,
    int? totalLeadContacts,
    int? todayLeadContacts,
    int? scheduledTotal,
    int? scheduledToday,
    int? completedTotal,
    int? completedToday,
    int? pendingTotal,
    int? pendingToday,
    int? incomingTotal,
    int? incomingToday,
    int? outgoingTotal,
    int? outgoingToday,
    int? missedTotal,
    int? missedToday,
    int? notAnsweredTotal,
    int? notAnsweredToday,
  }) {
    return GetStaticStatistics()
      ..totalLeads = totalLeads ?? this.totalLeads
      ..todayLeads = todayLeads ?? this.todayLeads
      ..totalFormSubmitted = totalFormSubmitted ?? this.totalFormSubmitted
      ..todayFormSubmitted = todayFormSubmitted ?? this.todayFormSubmitted
      ..totalLeadContacts = totalLeadContacts ?? this.totalLeadContacts
      ..todayLeadContacts = todayLeadContacts ?? this.todayLeadContacts
      ..scheduledTotal = scheduledTotal ?? this.scheduledTotal
      ..scheduledToday = scheduledToday ?? this.scheduledToday
      ..completedTotal = completedTotal ?? this.completedTotal
      ..completedToday = completedToday ?? this.completedToday
      ..pendingTotal = pendingTotal ?? this.pendingTotal
      ..pendingToday = pendingToday ?? this.pendingToday
      ..incomingTotal = incomingTotal ?? this.incomingTotal
      ..incomingToday = incomingToday ?? this.incomingToday
      ..outgoingTotal = outgoingTotal ?? this.outgoingTotal
      ..outgoingToday = outgoingToday ?? this.outgoingToday
      ..missedTotal = missedTotal ?? this.missedTotal
      ..missedToday = missedToday ?? this.missedToday
      ..notAnsweredTotal = notAnsweredTotal ?? this.notAnsweredTotal
      ..notAnsweredToday = notAnsweredToday ?? this.notAnsweredToday;
  }
}