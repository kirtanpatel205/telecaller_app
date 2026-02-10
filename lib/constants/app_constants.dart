import 'package:flutter/foundation.dart';

class AppConstants {
  const AppConstants._();

  static const String BASE_URL = 'https://wa-test.digibulkmarketing.com/api';
  // static const String _baseUrlRelease = 'https://api.digibulkmarketing.com';

  // Dynamic API URL based on build mode
  // static String get API_URL => kDebugMode ? BASE_URL : _baseUrlRelease;

  static String get API_URL => kDebugMode ? BASE_URL : BASE_URL;

  static const Duration timeout = Duration(seconds: 30);

  static const String ONE_SIGNAL_APP_KEY =
      'd8426638-0e2b-493a-aee1-9fcee2f1990b';

  // Cache storage
  static const String TOKEN =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY1YzFjODFlZGExNTUzNTZhZGQ3NDY0NyIsImlhdCI6MTcyMDA4MjAxNiwiZXhwIjoxNzIyNjc0MDE2fQ.EfqLVHpalTysNm-7YOhjvDD-K9ZZkZH92VxWfEaP7Hg';
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
  static const String TIMEBETWEENCALL = 'timeBetweenCall';
  static const String SETTINGCALL = 'settingCall';
  static const String SLEEPMODE = 'sleepMode';
  static const String LANGUAGE = 'language';
  static const String IS_DARK_MODE = 'isDarkMode';
  static const String UPLOAD_PROCESSED = 'upload_processed';
  static const String FCM_TOKEN = '';

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


}
