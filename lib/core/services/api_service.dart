

import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';




import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'package:telecaller_app/core/network/dio_client.dart';


class ApiService extends GetxService{
  var totalCommissions;
  dio.Dio _dio = new dio.Dio(dio.BaseOptions(
    //connectTimeout: 5,
    //receiveTimeout: 20
  ));
  late DioClient client;

  static ApiService to = Get.find();
  RxString search = "".obs;

  Future<void> init() async {
    //_dio.interceptors.add(LoggingInterceptor());

    _dio.interceptors.add(PrettyDioLogger());
    // customization
    /*_dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90));*/
    client = new DioClient(_dio);
  }
}
