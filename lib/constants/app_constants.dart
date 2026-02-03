import 'package:flutter/foundation.dart';

class AppConstants {
  const AppConstants._();

  static const String BASE_URL = 'https://api-test.digibulkmarketing.com';
  static const String _baseUrlRelease = 'https://api.digibulkmarketing.com';

  // Dynamic API URL based on build mode
  // static String get API_URL => kDebugMode ? BASE_URL : _baseUrlRelease;

  static String get API_URL => kDebugMode ? _baseUrlRelease : _baseUrlRelease;

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

  // API Endpoints (non-const because they depend on API_URL)
  static String API_PROFILE_SAVE = '$API_URL/profile/save';

  // get phoneNumber customer
  static String API_CUSTOMER_PHONE = '$API_URL/employee/customer/phone';




  static String API_SEND_OTP = '$API_URL/employee/send-otp';
  static String API_VERIFY_OTP = '$API_URL/employee/verify-otp';
  static String ACTIVE_COUPON = '$API_URL/employee/coupon-active';
  static String API_ALL_NOTES = '$API_URL/employee/notes';
  static String API_ADD_NOTE = '$API_URL/employee/note/add';
  static String API_DELETE_NOTE = '$API_URL/employee/note/remove';
  static String API_NOTIFICATION = '$API_URL/employee/notifications';
  static String API_CUSTOMER_RECENT = '$API_URL/employee/customer/create';
  static String API_GET_SETTINGS = '$API_URL/employee/settings';
  static String API_SET_SETTINGS = '$API_URL/employee/setting/save';
  static String API_SETTINGS_STATICS = '$API_URL/employee/setting/statics';
  static String API_TOTAl_COMMISION = '$API_URL/employee/comm';
  static String API_COMMISION = '$API_URL/employee/commission';
  static String API_COMMISSION_CHART = '$API_URL/employee/chart/commission';
  static String API_CALL_CHART = '$API_URL/employee/chart/calls';
  static String API_CALL_TASKS = '$API_URL/employee/call-tasks';
  static String API_CREATE_CALL = '$API_URL/employee/call/start';
  static String API_END_CALL = '$API_URL/employee/call/end';
  static String API_CALL_LOG = '$API_URL/employee/sync-call-logs';
  static String CURRECNYCHECK = '$API_URL/app';
  static String API_PROFILE = '$API_URL/auth/profile';
  static String API_UPDATE_PROFILE = '$API_URL/auth/profile/save';
  static String API_UPDATE_PROFILE_IMAGE = '$API_URL/app/upload-image';
  static String API_CALL_LEADS = '$API_URL/employee/lead/all';
  static String API_LEADS_BYID = '$API_URL/employee/lead/';
  static String API_CALL_HISTORY = '$API_URL/employee/lead/contact/';
  static String API_LEADS_UPDATE = '$API_URL/employee/lead/log/update';
  static String API_PRODUCT_DETAIL = '$API_URL/product';
  static String API_ALLPRODUCT = '$API_URL/product/all';
  static String API_ORDERS = '$API_URL/order/employee/all';
  static String API_ORDERS_DELETE = '$API_URL/employee/delete-draft';
  static String API_ORDERBYID = '$API_URL/order/employee/';
  static String API_CUSTOMER = '$API_URL/employee/customer/all';
  static String API_CUSTOMER_DETAILS = '$API_URL/employee/customer/';
  static String API_CUSTOMER_UPDATE = '$API_URL/employee/customer/save';
  static String API_ADD_CUSTOMER = '$API_URL/employee/customer/create';
  static String API_EXCHANGE_RATE = '$API_URL/panel/exchange-rates';
  static String API_PAYMENT_GATEWAYS = '$API_URL/panel/details/employee';
  static String API_ORDER = '$API_URL/order/employee/place-order';
  static String API_SAVE_DRAFT = '$API_URL/employee/save-draft';
  static String COUPONS = '$API_URL/employee/coupon/all';
  static String CREATE_COUPON = '$API_URL/employee/coupon/add';
  static String DELETE_COUPON = '$API_URL/employee/coupon/delete';
  static String UPDATE_COUPON = '$API_URL/employee/coupon/save';
  static String COUPON_BY_ID = '$API_URL/employee/coupon/';
  static String SAVE_FCM_TOKEN = '$API_URL/employee/save/fcm-token';
  static String APPLY_COUPON = '$API_URL/employee/coupon/apply';
  static String API_ACTION_CHART = '$API_URL/employee/charts';
  static String API_STATISTIC = '$API_URL/employee/statistics';
  static String API_SESSION_LOGOUT = '$API_URL/auth/session/logout';

  static const String MASTER_RESELLER_ID = '626f85e0544a264104223e37';
}
