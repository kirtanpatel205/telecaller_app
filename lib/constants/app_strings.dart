import 'package:get/get.dart';

class AppStrings extends Translations {
  AppStrings._();

  static const String appName = "Telecaller";

  static const unknownError = 'Unknow error! Please try again after some time.';
  static const connectionTimeout =
      'Connection timeout. Please try again after some time.';
  static const noConnection = 'No connection. Please turn on your internet!';
  static const unauthorize = 'Unauthorize. Please login again!';
  static const String ok = 'Ok';
  static const String error = 'Error';
  static const String noInternet = 'No internet. Please try again later.';
  static const String logOut = 'Log out';
  static const String retry = 'Retry';
  static const String somethingWentWrong = 'Something went wrong.';
  static const String home = 'Home';
  static const emailAddress = 'Email Address';
  static const mobileNumber = 'Mobile Number';
  static const String emailOrMobile = '$emailAddress or $mobileNumber';
  static const String cantBeEmpty = "can't be empty.";
  static const String fieldCantBeEmpty = 'Field $cantBeEmpty';
  static const String numberCantBeEmpty = '$emailOrMobile $cantBeEmpty';
  static const String emailCantBeEmpty = 'Email $cantBeEmpty';
  static const String enterValid = 'Please enter a valid';
  static const String enterValidNumber = '$enterValid $mobileNumber.';
  static const String enterValidEmail = '$enterValid email.';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm $password';
  static const String enterPassword = 'Enter $password';
  static const String passwordCantBeEmpty = '$password $cantBeEmpty';
  static const String passwordValidation =
      '$password must be at least 8 characters long.';
  static const confirmPasswordValidation =
      '$password and Confirm password should be same.';
  static const otpValidation = 'Invalid OTP';
  static const gallery = 'Gallery';
  static const camera = 'Camera';
  static const mobile = 'Mobile';
  static const from = 'From';
  static const to = 'To';
  static const success = 'Success';
  static const checkboxValidation = 'Dummy Checkbox Validation Message';
  static const task = 'Task';
  static const Pending_call = 'Pending call';
  static const Completed_call = 'Completed call';
  static const Product = 'Product';
  static const aaa = "validconctnum";
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          'app_name': 'Its Me',
          'error': 'Error',

          //common
          'noResultFound': 'No Result Found',

          //refresh
          'pullToLoadMore': 'Pull to Load more',
          'loadFail': 'Load Failed!',
          'releaseToLoadMore': 'Release to load more',
          'noData': 'No more Data',

          //menu
          'settings': 'Settings',

          //connectivity
          'noInternetConnection': 'No internet connection',
          'pleaseCheckInternet': 'Please checking internet connection!',

          //login
          'signIn': 'Sign In',

          //google place
          'nearbyPlaces': 'Nearby Places',
          'tapSelectLocation': 'Tap to select this location',
          'searchPlace': 'Please write input in search field',

          'somethingWentWrong': "Something went wrong."
        }
      };
}
