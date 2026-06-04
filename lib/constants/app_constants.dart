import 'package:flutter/foundation.dart';

class AppConstants {
  const AppConstants._();

  static const String BASE_URL = 'https://api-test.digibulkmarketing.com';

  static const String _baseUrlRelease =
      'https://app.digibulkmarketing.com/api/';

  static const String _baseSocketUrlDebug =
      'https://api-test.digibulkmarketing.com';
  static const String _baseSocketUrlRelease =
      'https://api.digibulkmarketing.com';

  static String get SOCKET_URL =>
      kDebugMode ? _baseSocketUrlDebug : _baseSocketUrlRelease;

  // Dynamic API URL based on build mode
  static String get API_URL => kDebugMode ? BASE_URL : _baseUrlRelease;

  // static String get API_URL => kDebugMode ? BASE_URL : BASE_URL;

  static const Duration timeout = Duration(seconds: 30);

  static const String ONE_SIGNAL_APP_KEY =
      'd8426638-0e2b-493a-aee1-9fcee2f1990b';

  // Cache storage
  static const String TOKEN = 'auth_token';
  static const String PROFILE_TOKEN = 'profileToken';
  static const String DL_REFER_USER = 'dlReferUser';
  static const String TOKEN_TIMESTAMP = 'authTokenTimestamp';
  static const String PROFILE = 'profile';
  static const String SELECTED_PROFILE = '0';
  static const String GROUP_PROFILE = 'groupProfile';
  static const String INSURANCE = 'insurance';
  static const String USER_ID = 'userId';
  static const String ISLOGGING = 'isLoggedIn';
  static const String FIRE_USER_ID = 'fireUserId';
  static const String EMAIL_ID = 'email';
  static const String PHONE = 'phone';
  static const String LANGUAGE = 'language';
  static const String IS_DARK_MODE = 'isDarkMode';
  static const String UPLOAD_PROCESSED = 'upload_processed';
  static const String FCM_TOKEN = '';

  static const String ALLOW_CALL_TYPE_APP = "app";
  static const String ALLOW_CALL_TYPE_WEB = "web";

  // Directories
  static const String DIR_DRAFT = '/drafts';
  static const String DIR_VIDEOS = '/videos';
  static const String DIR_SOUNDS = '/sounds';
  static const String DIR_IMAGES = '/images';

  // Regex
  static const String REGEX_USERNAME = r'\B@[a-zA-Z0-9_.]+\b';
  static const String REGEX_HASHTAG = r'\B#[a-zA-Z0-9]+\b';

  static String API_SEND_OTP = '$API_URL/telecaller/send-otp';
  static String API_VERYFY_OTP = '$API_URL/telecaller/verify-otp';
  static String API_PROFILE = '$API_URL/auth/profile';
  static String API_UPDATE_PROFILE = '$API_URL/auth/profile/save';
  static String API_UPDATE_PROFILE_IMAGE = '$API_URL/app/upload-image';
  static String API_UPLOAD_MEDIA = '$API_URL/app/upload-media';

  // lead all

  static String API_ALL_LEAD = '$API_URL/telecaller/lead/all';
  static String API_GET_CALL = '$API_URL/telecaller/lead-contact/all';
  static String API_LEADS_UPDATE = '$API_URL/telecaller/lead/log/update';
  static String API_LEAD_FORM_SUBMIT = '$API_URL/telecaller/submit/form';
  static String API_LEAD_FORM_UPDATE = '$API_URL/telecaller/form-response/save';

  // fcm token

  static String SAVE_FCM_TOKEN = '$API_URL/telecaller/save/fcm-token';

  //dashboard overview
  static String API_GET_DASHBOARD_STATISTICS =
      '$API_URL/telecaller/dashboard-statistics';

  //chart data
  static String API_CALL_CHART = '$API_URL/telecaller/calls/analytics';
  static String API_LEAD_CHART = '$API_URL/telecaller/lead-contacts/analytics';
  static String API_CALL_LOG = '$API_URL/telecaller/sync-call-logs';
  static String API_SESSION = '$API_URL/auth/session/logout';
  static String API_USER_SETTING = '$API_URL/telecaller/user-setting';
  static String API_SWITCH_MODE = '$API_URL/telecaller/switch-mode';
  static String API_FORM_RESPONSE =
      '$API_URL/telecaller/form-response/lead-contact';
  static String API_PANEL_RESPONSE =
      '$API_URL/panel/details/telecallerRequest';




}
