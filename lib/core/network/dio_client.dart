import 'package:dio/dio.dart';
import 'package:telecaller_app/constants/app_constants.dart';
import 'package:telecaller_app/core/controllers/auth_controller.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:telecaller_app/core/helpers/storage.dart';

class DioClient {
  final Dio _dio;
  static bool _isSigningOut = false;


  DioClient(this._dio) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (
          RequestOptions options,
          RequestInterceptorHandler handler,
        ) async {
          // Use the async getToken which is cross-isolate safe
          String? token = await Storage.getToken();
          print("token :$token");
          if (token != null && token.isNotEmpty) {
            options.headers["authorization"] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          // ⚠️ IMPORTANT: Logout endpoint par 401 aye to IGNORE karo
          // Nahi to infinite loop thayse!
          if (error.requestOptions.path.contains('/auth/session/logout')) {
            print("⚠️ Logout endpoint returned 401 - skipping auto logout");
            return handler.next(error);
          }

          // Anya API requests par 401/403 aye to logout trigger karo
          if (error.response != null &&
              (error.response!.statusCode == 401 ||
                  error.response!.statusCode == 403)) {
            if (!_isSigningOut) {
              print(
                "🔴 Auto logout triggered due to ${error.response!.statusCode}",
              );
              _isSigningOut = true;
              try {
                // Check if we are in the main isolate (where AuthController exists)
                if (Get.isRegistered<AuthController>()) {
                  await AuthController.to.signOut(localOnly: true);
                } else {
                  print(
                    "⚠️ AuthController not found in this isolate (Background Service). Clearing token manually.",
                  );
                  await Storage.removeValue(AppConstants.TOKEN);
                  await Storage.saveToSharedPrefs(AppConstants.TOKEN, "");
                  // Optionally stop the service if we are in background
                }
              } catch (e) {
                print("❌ Error during auto logout: $e");
              } finally {
                _isSigningOut = false;
              }
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  bool isTokenExpired() {
    if (Storage.hasData(AppConstants.TOKEN_TIMESTAMP)) {
      int timestamp = Storage.getValue(AppConstants.TOKEN_TIMESTAMP);
      DateTime expiryDate = DateTime.fromMillisecondsSinceEpoch(
        timestamp * 1000,
      );
      bool isExpired = expiryDate.compareTo(DateTime.now()) < 0;
      return isExpired;
    } else {
      return true;
    }
  }

  Future<dynamic> get(
    String uri, {
    Map<String, dynamic>? data = const {},
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      if (queryParameters == null) {
        queryParameters = {};
      }

      final Response response = await _dio.get(
        uri,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      return response.data;
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<dynamic> post(
    String uri, {
    Map<String, dynamic>? data = const {},
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool isRaw = false,
  }) async {
    try {
      final Response response = await _dio.post(
        uri,
        data: isRaw ? data : FormData.fromMap(data!),
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return response.data;
    } catch (e) {
      print("DIO ERROR - $e");
      throw e;
    }
  }
}
