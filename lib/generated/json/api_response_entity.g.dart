import 'package:telecaller_app/generated/json/base/json_convert_content.dart';
import 'package:telecaller_app/core/models/api_response_entity.dart';

ApiResponseEntity $ApiResponseEntityFromJson(Map<String, dynamic> json) {
  final ApiResponseEntity apiResponseEntity = ApiResponseEntity();
  final bool? status = jsonConvert.convert<bool>(json['status']);
  if (status != null) {
    apiResponseEntity.status = status;
  }
  final String? message = jsonConvert.convert<String>(json['message']);
  if (message != null) {
    apiResponseEntity.message = message;
  }
  return apiResponseEntity;
}

Map<String, dynamic> $ApiResponseEntityToJson(ApiResponseEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['status'] = entity.status;
  data['message'] = entity.message;
  return data;
}

extension ApiResponseEntityExtension on ApiResponseEntity {
  ApiResponseEntity copyWith({
    bool? status,
    String? message,
  }) {
    return ApiResponseEntity()
      ..status = status ?? this.status
      ..message = message ?? this.message;
  }
}