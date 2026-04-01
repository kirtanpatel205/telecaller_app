import 'package:telecaller_app/generated/json/base/json_convert_content.dart';
import 'package:telecaller_app/core/models/language_entity.dart';

LanguageEntity $LanguageEntityFromJson(Map<String, dynamic> json) {
  final LanguageEntity languageEntity = LanguageEntity();
  final String? key = jsonConvert.convert<String>(json['key']);
  if (key != null) {
    languageEntity.key = key;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    languageEntity.name = name;
  }
  return languageEntity;
}

Map<String, dynamic> $LanguageEntityToJson(LanguageEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['key'] = entity.key;
  data['name'] = entity.name;
  return data;
}

extension LanguageEntityExtension on LanguageEntity {
  LanguageEntity copyWith({
    String? key,
    String? name,
  }) {
    return LanguageEntity()
      ..key = key ?? this.key
      ..name = name ?? this.name;
  }
}