import 'package:get/get.dart';
import 'package:telecaller_app/ui/views/auto_dialer/autodialer_binding.dart';
import 'package:telecaller_app/ui/views/auto_dialer/autodialer_page.dart';
import 'package:telecaller_app/ui/views/edit_profile/edit_profile_binding.dart';
import 'package:telecaller_app/ui/views/edit_profile/edit_profile_page.dart';
import 'package:telecaller_app/ui/views/home/home_binding.dart';
import 'package:telecaller_app/ui/views/home/home_page.dart';
import 'package:telecaller_app/ui/views/language/language_binding.dart';
import 'package:telecaller_app/ui/views/language/language_page.dart';
import 'package:telecaller_app/ui/views/leads/leads_binding.dart';
import 'package:telecaller_app/ui/views/leads/leads_page.dart';
import 'package:telecaller_app/ui/views/leadsContact/leadscontact_binding.dart';
import 'package:telecaller_app/ui/views/leadsContact/leadscontact_page.dart';
import 'package:telecaller_app/ui/views/login/login_binding.dart';
import 'package:telecaller_app/ui/views/login/login_page.dart';
import 'package:telecaller_app/ui/views/notifiction/notifiction_binding.dart';
import 'package:telecaller_app/ui/views/notifiction/notifiction_page.dart';
import 'package:telecaller_app/ui/views/otp/otp_binding.dart';
import 'package:telecaller_app/ui/views/otp/otp_page.dart';
import 'package:telecaller_app/ui/views/setting/setting_binding.dart';
import 'package:telecaller_app/ui/views/setting/setting_page.dart';
import 'package:telecaller_app/ui/views/splash/splash_binding.dart';
import 'package:telecaller_app/ui/views/splash/splash_page.dart';
import 'package:telecaller_app/ui/views/welcome/welcome_binding.dart';
import 'package:telecaller_app/ui/views/welcome/welcome_page.dart';
import 'package:telecaller_app/ui/views/sim_selection/sim_selection_binding.dart';
import 'package:telecaller_app/ui/views/sim_selection/sim_selection_page.dart';
import 'package:telecaller_app/ui/views/privacy_policy/privacy_policy_page.dart';
import 'package:telecaller_app/ui/views/terms_conditions/terms_conditions_page.dart';

import 'app_routes.dart';

class AppPages {
  AppPages._();

  static var INITIAL = Routes.SPLASH;

  // static var overlay = Routes.OVERLAY;

  static final List<GetPage> routes = [
    GetPage(
      name: Paths.SPLASH,
      page: () => SplashPage(),
      binding: SplashBinding(),
    ),

    GetPage(
      name: Paths.WELCOME,
      page: () => WelcomePage(),
      binding: WelcomeBinding(),
    ),
    GetPage(
      name: Paths.LOGIN,
      page: () => LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Paths.SIM_SELECTION,
      page: () => SimSelectionPage(),
      binding: SimSelectionBinding(),
    ),
    GetPage(name: Paths.OTP, page: () => OtpPage(), binding: OtpBinding()),
    GetPage(name: Paths.HOME, page: () => HomePage(), binding: HomeBinding()),
    GetPage(
      name: Paths.EDITPROFILE,
      binding: EditProfileBinding(),
      page: () => EditProfilePage(),
    ),
    GetPage(
      name: Paths.LEADS,
      binding: LeadsBinding(),
      page: () => LeadsPage(),
    ),
    GetPage(
      name: Paths.AUTO_DIAL,
      binding: AutodialerBinding(),
      page: () => AutoDialerPage(),
    ),
    GetPage(
      name: Paths.SETTING,
      binding: SettingBinding(),
      page: () => SettingPage(),
    ),
    GetPage(
      name: Paths.LEADSCONTACT,
      binding: LeadscontactBinding(),
      page: () => LeadsContactPage(),
    ),
    GetPage(
      name: Paths.LANGUAGE,
      binding: LanguageBinding(),
      page: () => LanguagePage(),
    ),
    GetPage(name: Paths.PRIVACY_POLICY, page: () => const PrivacyPolicyPage()),
    GetPage(
      name: Paths.TERMS_CONDITIONS,
      page: () => const TermsConditionsPage(),
    ),
    GetPage(
      name: Paths.NOTIFICATION,
      page: () => NotifictionPage(),
      binding: NotifictionBinding(),
    ),

    // GetPage(
    //     name: Paths.OVERLAY,
    //     page: () => OverlayPages(),
    //     binding: OverlayBinding()),
  ];
}
