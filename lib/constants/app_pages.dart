
import 'package:get/get.dart';
import 'package:telecaller_app/ui/views/home/home_binding.dart';
import 'package:telecaller_app/ui/views/home/home_page.dart';
import 'package:telecaller_app/ui/views/login/login_binding.dart';
import 'package:telecaller_app/ui/views/login/login_page.dart';
import 'package:telecaller_app/ui/views/otp/otp_binding.dart';
import 'package:telecaller_app/ui/views/otp/otp_page.dart';
import 'package:telecaller_app/ui/views/splash/splash_binding.dart';
import 'package:telecaller_app/ui/views/splash/splash_page.dart';
import 'package:telecaller_app/ui/views/welcome/welcome_binding.dart';
import 'package:telecaller_app/ui/views/welcome/welcome_page.dart';

import 'app_routes.dart';

class AppPages {
  AppPages._();

  static var INITIAL = Routes.SPLASH;

  // static var overlay = Routes.OVERLAY;

  static final List<GetPage> routes = [
    GetPage(
        name: Paths.SPLASH, page: () => SplashPage(), binding: SplashBinding()),

    GetPage(
        name: Paths.WELCOME,
        page: () => WelcomePage(),
        binding: WelcomeBinding()),
    GetPage(
        name: Paths.LOGIN, page: () => LoginPage(), binding: LoginBinding()),
    GetPage(name: Paths.OTP, page: () => OtpPage(), binding: OtpBinding()),
    GetPage(name: Paths.HOME, page: () => HomePage(), binding: HomeBinding()),
  ];
}
