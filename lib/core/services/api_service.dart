import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:telecaller_app/constants/app_constants.dart';
import 'package:telecaller_app/core/models/all_lead_entity.dart';
import 'package:telecaller_app/core/models/api_response_entity.dart';
import 'package:telecaller_app/core/models/call_lead_update_response_entity.dart';
import 'package:telecaller_app/core/models/lead_contact_id_entity.dart';
import 'package:telecaller_app/core/models/login_response_entity.dart';

import 'package:telecaller_app/core/network/dio_client.dart';

class ApiService extends GetxService {
  var totalCommissions;
  dio.Dio _dio = new dio.Dio(
    dio.BaseOptions(
      //connectTimeout: 5,
      //receiveTimeout: 20
    ),
  );
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

  Future<ApiResponseEntity> sendOtp({
    String phone = "",
    String authType = "phone",
  }) async {
    Map<String, dynamic> response = await client.post(
      AppConstants.API_SEND_OTP,
      data: {"phone": phone, "auth_type": authType},
    );
    print(phone);
    return ApiResponseEntity.fromJson(response);
  }

  Future<LoginResponseEntity> verifyOtp({
    String phone = "",
    String authType = "phone",
    String otp = "",
  }) async {
    Map<String, dynamic> response = await client.post(
      AppConstants.API_VERYFY_OTP,
      data: {"phone": phone, "auth_type": authType, "otp": otp},
    );
    print("abs $response");
    return LoginResponseEntity.fromJson(response);
  }

  //profile
  Future<LoginResponseProfile> profile() async {
    Map<String, dynamic> response = await client.get(AppConstants.API_PROFILE);
    print("profile: ${json.encode(response)}");
    print("profile: ${response["profile"]["name"]}");
    //developer.log("${response}");
    LoginResponseProfile profile = LoginResponseProfile.fromJson(
      response["profile"],
    );
    print("profile data: ${profile.name}");
    return profile;
  }

  Future<ApiResponseEntity> Updateprofile({
    required String name,
    required String lastName,
    required String addressLine1,
    required String addressLine2,
    required String city,
    required String state,
    required String zipCode,
    required String profile,
    required String country,
    required String email,
  }) async {
    final data = {
      "name": name,
      "lastname": lastName,
      "email": email,
      "profile": profile,
      "address": {
        "addressLine1": addressLine1,
        "addressLine2": addressLine2,
        "city": city,
        "state": state,
        "zip": zipCode,
        "country": country,
      },
    };
    Map<String, dynamic> response = await client.post(
      AppConstants.API_UPDATE_PROFILE,
      isRaw: true,
      data: data,
    );
    developer.log('ghj${addressLine1}');
    print(response);
    print("response : $data ${data.values}");
    print("profile update${response}");
    return ApiResponseEntity.fromJson(response);
  }

  Future<Map<String, dynamic>> UpdateprofileImage({required File name}) async {
    var multipartFile = await dio.MultipartFile.fromFile(
      name.path,
      filename: name.uri.pathSegments.last, // Use the actual file name
    );
    try {
      Map<String, dynamic> response = await client.post(
        AppConstants.API_UPDATE_PROFILE_IMAGE,
        data: {"type": "image", "file": multipartFile},
        // isRaw: true,
      );

      print("response : $multipartFile");
      print("profile update $response");
      return response;
    } catch (e) {
      print("Upload error: $e");
      return {"status": false, "message": "Image upload failed"};
    }
  }

  Future<AllLeadEntity> allLead({int? page = 0, int? limit = 10}) async {
    Map<String, dynamic> response = await client.post(
      AppConstants.API_ALL_LEAD,
      data: {
        "page": page,
        "limit": limit,
        // "search": search.value,
      },
    );
    return AllLeadEntity.fromJson(response);
  }

  Future<ApiResponseEntity> saveFCMToken(String token) async {
    Map<String, dynamic> response = await client.post(
      AppConstants.SAVE_FCM_TOKEN,
      data: {"token": token},
    );
    return ApiResponseEntity.fromJson(response);
  }

  Future<LeadContactIdEntity> getCallLead({
    String? id,
    int? page = 0,

    int? limit = 10,
  }) async {
    Map<String, dynamic> response = await client.post(
      AppConstants.API_GET_CALL,
      data: {"lead_id": id, "page": page, "limit": limit},
    );
    return LeadContactIdEntity.fromJson(response);
  }

  // call log update

  Future<CallLeadUpdateResponseEntity> callUpdateLeadById({
    String lead_id = '',
    String type = "outgoing",
    String answertype = "interested",
    String answer = "",
    int duration = 180,
  }) async {
    print("callUpdateLeadById ${lead_id} $duration $type $answertype $answer");
    Map<String, dynamic> response = await client.post(
      "${AppConstants.API_LEADS_UPDATE}",
      isRaw: true,
      data: {
        "id": lead_id,
        "type": type,
        "answertype": answertype,
        "duration": duration,
        "answer": answer,
      },
    );
    print("callUpdateLeadById response: ${response}");
    return CallLeadUpdateResponseEntity.fromJson(response);
  }




}
