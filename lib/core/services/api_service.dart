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
import 'package:telecaller_app/core/models/get_static_entity.dart';
import 'package:telecaller_app/core/models/lead_chart_entity.dart';
import 'package:telecaller_app/core/models/lead_contact_id_entity.dart';
import 'package:telecaller_app/core/models/login_response_entity.dart';
import 'package:telecaller_app/core/models/call_chart_entity.dart';

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
      print("📤 POST to: ${AppConstants.API_UPDATE_PROFILE_IMAGE}");
      print("📦 Payload: {type: image, file: ${name.path}}");
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

  Future<Map<String, dynamic>> uploadMedia({
    required File file,
    required String type,
  }) async {

    // 🔹 Normalize type
    String apiType = type.toLowerCase();
    print("📦 TYPE BEFORE: $apiType");

    if (apiType.contains("excel") || apiType == "file") {
      apiType = "document";
    } else if (apiType == "image") {
      apiType = "image";
    } else if (apiType == "video") {
      apiType = "video";
    }

    print("✅ TYPE AFTER: $apiType");

    var multipartFile = await dio.MultipartFile.fromFile(
      file.path,
      filename: file.uri.pathSegments.last,
    );

    try {
      print("📤 API: ${AppConstants.API_UPLOAD_MEDIA}");

      Map<String, dynamic> response = await client.post(
        AppConstants.API_UPLOAD_MEDIA,
        data: {
          "type": apiType,
          "media": multipartFile,
        },
      );

      print("📥 FULL RESPONSE: $response");

      // 🔥 MAIN FIX START
      if (response["status"] == true &&
          response["downloadUrl"] != null) {

        String url = response["downloadUrl"];

        // 👉 file name extract
        String name = file.path.split('/').last;

        Map<String, dynamic> finalData = {
          "url": url,
          "name": name,
        };

        print("✅ FINAL RETURN: $finalData");

        return finalData;
      }
      // 🔥 MAIN FIX END

      return {
        "status": false,
        "message": response["message"] ?? "Upload failed"
      };

    } on dio.DioException catch (e) {
      print("❌ Dio Error: ${e.response?.statusCode}");

      if (e.response?.statusCode == 413) {
        return {
          "status": false,
          "message": "File too large (Max 1-2MB allowed)"
        };
      }

      return {
        "status": false,
        "message": e.message
      };

    } catch (e) {
      print("❌ Upload Error: $e");

      return {
        "status": false,
        "message": "Upload failed"
      };
    }
  }
  Future<AllLeadEntity> allLead({
    int? page = 0,
    int? limit = 10,
    String? search,
    Map<String, dynamic>? filterBy,
    String? sortBy,
  }) async {
    Map<String, dynamic> data = {
      "page": page,
      "limit": limit,
      "search": search ?? "",
      "sort_by": sortBy,
      "filter_by": filterBy,
    };
    print("allLead request data $data");
    Map<String, dynamic> response = await client.post(
      AppConstants.API_ALL_LEAD,
      isRaw: true,
      data: data,
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
    String? search,
    Map<String, dynamic>? filterBy,
    String? sortBy,
  }) async {
    Map<String, dynamic> data = {
      "lead_id": id,
      "page": page,
      "limit": limit,
      "search": search ?? "",
      "sort_by": sortBy,
      "filter_by": filterBy,
    };
    print("getCallLead request data $data");
    Map<String, dynamic> response = await client.post(
      AppConstants.API_GET_CALL,
      isRaw: true,
      data: data,
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

  Future<GetStaticEntity> DashboardStastics() async {
    Map<String, dynamic> response = await client.get(
      AppConstants.API_GET_DASHBOARD_STATISTICS,
    );
    print("response details ${response}");
    return GetStaticEntity.fromJson(response);
  }

  Future<CallChartEntity> callChart({
    String? filter = "today",
    String startDate = "",
    String endDate = "",
    String simNumbers = "",
  }) async {
    Map<String, dynamic> data ={
      "filter_by":{
        "type":filter,
        if(startDate != null && startDate.isNotEmpty)
        "start_date":startDate,
        if(endDate != null && endDate.isNotEmpty)
        "end_date":endDate,
        // if(simNumbers != null && simNumbers.isNotEmpty)
        "simNumbers": []
      }
    };
print("callChart request data $data");
    Map<String, dynamic> response = await client.post(AppConstants.API_CALL_CHART,isRaw: true, data: data
    );
    print("callChart response details $response");
    return CallChartEntity.fromJson(response);
  }

  Future<LeadChartEntity> leadChart({
    String? filter = "today",
    String startDate = "",
    String endDate = "",
  }) async {
    Map<String, dynamic> data ={
      "filter_by":{
        "type":filter,
        if(startDate != null && startDate.isNotEmpty)
        "start_date":startDate,
        if(endDate != null && endDate.isNotEmpty)
        "end_date":endDate,
      }
    };
    print("callChart request data $data");
    Map<String, dynamic> response = await client.post(AppConstants.API_LEAD_CHART,isRaw: true, data: data
    );
    print("callChart response details $response");
    return LeadChartEntity.fromJson(response);
  }

  Future<ApiResponseEntity> submitCallForm(Map<String, dynamic> data) async {
    print("📡 Submitting call form data: $data");
    Map<String, dynamic> response = await client.post(
      AppConstants.API_LEAD_FORM_SUBMIT,
      isRaw: true,
      data: data,
    );
    print("✅ Form submission response: $response");
    return ApiResponseEntity.fromJson(response);
  }
}
