import 'package:get/get.dart';

import 'app_strings.dart';

abstract class AppErrors implements Exception {
  String? get message;

  AppErrors() {
    printInfo(info: message!);
  }
}

class ApiError extends AppErrors {
  @override
  final String message;

  ApiError({
    this.message = AppStrings.unknownError,
  });
}

class TimeoutError extends AppErrors {
  @override
  final String? message;

  TimeoutError({
    this.message = AppStrings.connectionTimeout,
  });
}

class NoConnectionError extends AppErrors {
  @override
  final String message;

  NoConnectionError({
    this.message = AppStrings.noConnection,
  });
}

class UnauthorizeError extends AppErrors {
  @override
  final String message;

  UnauthorizeError({
    this.message = AppStrings.unauthorize,
  });
}
