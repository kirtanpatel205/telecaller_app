import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/core/helpers/storage.dart';
import 'package:telecaller_app/core/services/background_service_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_routes.dart';
import 'package:telecaller_app/ui/widgets/app_safe_area.dart';
import 'custom-appbar.dart';

class ProminentDisclosurePage extends StatefulWidget {
  const ProminentDisclosurePage({super.key});

  @override
  State<ProminentDisclosurePage> createState() =>
      _ProminentDisclosurePageState();
}

class _ProminentDisclosurePageState extends State<ProminentDisclosurePage> {
  bool acceptCallLog = false;
  bool acceptTermsPrivacy = false;
  bool isProcessing = false;

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);

    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          Get.snackbar(
            "Error",
            "Could not launch $url",
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          "Error",
          "Error launching URL: ${e.toString()}",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Future<void> _agree() async {
    if (!acceptCallLog || !acceptTermsPrivacy) {
      Get.snackbar(
        "Consent Required",
        "Please accept all permissions to continue",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      await Storage.saveValue("user_consent_given", true);

      if (mounted) {
        await BackgroundServiceManager.fetchAndSaveSimInfo();
        Get.offAllNamed(Routes.SIM_SELECTION);
      }
    } catch (e) {
      setState(() {
        isProcessing = false;
      });

      if (mounted) {
        Get.snackbar(
          "Error",
          "Failed to save consent. Please try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      }
    }
  }

  void _decline() {
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return AppSafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: CustomAppBar(
          leading: const SizedBox(),
          titleText: "Permission Disclosure",
          showBackButton: false,
        ),
        body: WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Stack(
            children: [
              // Top Right Decorative Ambient Light Circle
              Positioned(
                top: -60,
                right: -60,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.shade50.withOpacity(0.5),
                  ),
                ),
              ),
              // Bottom Left Decorative Ambient Light Circle
              Positioned(
                bottom: 120,
                left: -100,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.teal.shade50.withOpacity(0.4),
                  ),
                ),
              ),

              Column(
                children: [
                  // SCROLLABLE CONTENT AREA
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SECURITY SHIELD HEADER GRAPHIC
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.shade50,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Colors.blue.shade600, Colors.indigo.shade700],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.indigo.shade400.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.shield_rounded,
                                  size: 38,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // MAIN TITLE
                          const Center(
                            child: Text(
                              "Important Permission Disclosure & User Consent",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // APP INTRO / CRM DESCRIPTION
                          const Text(
                            "Digi Bulk Marketing – Telecaller is a company CRM and customer management application designed for registered telecallers. To provide its core business features, this app requires access to certain phone and system permissions.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.55,
                              color: Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // CALL LOG SECTION CARD
                          _buildSectionCard(
                            icon: Icons.phone_android_rounded,
                            iconColor: Colors.blue,
                            title: "Call Log & Phone Information Access",
                            content: "This app collects and processes call information such as:",
                            items: const [
                              "Phone numbers",
                              "Call Duration",
                              "Call type (incoming, outgoing, missed)",
                              "Call timestamp",
                            ],
                            extraContent: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                const Text(
                                  "This information is used only for business CRM functionality, including:",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildBulletList(const [
                                  "Identifying customers during incoming and outgoing calls",
                                  "Displaying customer details and interaction history during calls",
                                  "Automatically linking calls with customer records",
                                  "Tracking telecaller call activity and performance analytics",
                                  "Maintaining call history backup across authorized devices",
                                  "Supporting order creation and customer follow-ups",
                                ]),
                                const SizedBox(height: 12),
                                _buildSafeBadge(
                                  "The app does NOT record call audio or call content.",
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // WRITE CALL LOG SECTION CARD
                          _buildSectionCard(
                            icon: Icons.rate_review_rounded,
                            iconColor: Colors.indigo,
                            title: "Write Call Log Access",
                            content: "The app may create or update call interaction entries only for CRM tracking purposes such as:",
                            items: const [
                              "Tagging customer calls",
                              "Linking calls to customer orders",
                              "Maintaining business interaction history",
                            ],
                            extraContent: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                _buildSafeBadge(
                                  "The app does NOT delete or modify personal call records unrelated to company CRM usage.",
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // CALL SCREENING SECTION CARD
                          _buildSectionCard(
                            icon: Icons.picture_in_picture_alt_rounded,
                            iconColor: Colors.purple,
                            title: "Call Screening & Overlay Display",
                            content: "The app uses call screening and overlay permissions to:",
                            items: const [
                              "Detect incoming and outgoing calls",
                              "Show customer information on screen during calls",
                              "Allow telecallers to quickly create orders, notes, or CRM updates without interrupting calls",
                            ],
                          ),
                          const SizedBox(height: 16),

                          // BACKGROUND SERVICE SECTION CARD
                          _buildSectionCard(
                            icon: Icons.sync_rounded,
                            iconColor: Colors.teal,
                            title: "Background Service & Device Restart",
                            content: "The app may run background services and restart after device reboot to ensure:",
                            items: const [
                              "Continuous call detection",
                              "CRM data synchronization",
                              "Reliable telecaller productivity tools",
                            ],
                          ),
                          const SizedBox(height: 16),

                          // NOTIFICATIONS SECTION CARD
                          _buildSectionCard(
                            icon: Icons.notifications_active_rounded,
                            iconColor: Colors.pink,
                            title: "NOTIFICATIONS",
                            content: "Notification permission is used to:",
                            items: const [
                              "Alert telecallers about customer calls",
                              "Provide CRM reminders and business updates",
                            ],
                          ),
                          const SizedBox(height: 16),

                          // BATTERY OPTIMIZATION SECTION CARD
                          _buildSectionCard(
                            icon: Icons.battery_charging_full_rounded,
                            iconColor: Colors.orange,
                            title: "Battery Optimization & Foreground Services",
                            content: "The app may request battery optimization exemption and foreground service permissions to maintain reliable real-time call detection and CRM syncing.",
                            items: const [],
                          ),
                          const SizedBox(height: 16),

                          // DATA USAGE & SECURITY SECTION CARD
                          _buildSectionCard(
                            icon: Icons.lock_outline_rounded,
                            iconColor: Colors.green,
                            title: "Data Usage & Security",
                            content: "",
                            items: const [
                              "All collected information is used only for telecaller CRM and business communication features",
                              "Data is securely transmitted to company servers",
                              "Data is NOT sold, shared with third parties, or used for advertising",
                            ],
                            extraContent: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.blue.shade100,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.vpn_key_rounded,
                                        size: 16,
                                        color: Colors.blue.shade800,
                                      ),
                                      const SizedBox(width: 8),
                                      const Expanded(
                                        child: Text(
                                          "Customer interaction data is securely transmitted to:\nhttps://master.digibulkmarketing.com",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF1E3A8A),
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // USER CONTROL SECTION CARD
                          _buildSectionCard(
                            icon: Icons.touch_app_rounded,
                            iconColor: Colors.cyan,
                            title: "User Control",
                            content: "",
                            items: const [
                              "Permissions are requested only after your explicit consent",
                              "You may deny or revoke permissions anytime from device settings",
                              "If permissions are denied, call-related CRM features and caller identification may not function",
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // FIXED BOTTOM SECTION WITH TACTILE INTERACTIVE CONTROLS
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // CALL LOG CHECKBOX CARD
                        _buildCheckboxCard(
                          value: acceptCallLog,
                          onChanged: (v) {
                            setState(() {
                              acceptCallLog = v ?? false;
                            });
                          },
                          titleWidget: const Text(
                            "I allow Digi Bulk Marketing – Telecaller to access Call Log and Phone information for CRM and call management features.",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                              height: 1.45,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // TERMS & PRIVACY CHECKBOX CARD
                        _buildCheckboxCard(
                          value: acceptTermsPrivacy,
                          onChanged: (v) {
                            setState(() {
                              acceptTermsPrivacy = v ?? false;
                            });
                          },
                          titleWidget: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1E293B),
                                height: 1.45,
                              ),
                              children: [
                                const TextSpan(text: "I agree to the "),
                                TextSpan(
                                  text: "Terms & Conditions",
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      _launchUrl(
                                        'https://master.digibulkmarketing.com/terms-and-conditions',
                                      );
                                    },
                                ),
                                const TextSpan(text: " and "),
                                TextSpan(
                                  text: "Privacy Policy",
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      _launchUrl(
                                        'https://master.digibulkmarketing.com/privacy-policy',
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ACTION BUTTONS
                        Row(
                          children: [
                            // Decline Button
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: OutlinedButton(
                                  onPressed: isProcessing ? null : _decline,
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    side: BorderSide(
                                      color: isProcessing
                                          ? Colors.grey.shade200
                                          : Colors.red.shade300,
                                      width: 1.5,
                                    ),
                                    foregroundColor: Colors.red.shade600,
                                  ),
                                  child: const Text(
                                    "Decline",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Agree & Continue Button (with beautiful custom gradients)
                            Expanded(
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  gradient: (acceptCallLog && acceptTermsPrivacy && !isProcessing)
                                      ? LinearGradient(
                                          colors: [Colors.green.shade600, const Color(0xFF047857)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: (acceptCallLog && acceptTermsPrivacy && !isProcessing)
                                      ? null
                                      : Colors.grey.shade200,
                                  boxShadow: (acceptCallLog && acceptTermsPrivacy && !isProcessing)
                                      ? [
                                          BoxShadow(
                                            color: Colors.green.shade400.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: ElevatedButton(
                                  onPressed: (acceptCallLog && acceptTermsPrivacy && !isProcessing)
                                      ? _agree
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  child: isProcessing
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : const Text(
                                          "I Agree",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // DISCLOSURE CARD BUILDER
  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    required List<String> items,
    Widget? extraContent,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: ThemeData().copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            initiallyExpanded: true,
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            expandedAlignment: Alignment.topLeft,
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (content.isNotEmpty)
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
              if (content.isNotEmpty && items.isNotEmpty) const SizedBox(height: 8),
              if (items.isNotEmpty) _buildBulletList(items),
              if (extraContent != null) extraContent,
            ],
          ),
        ),
      ),
    );
  }

  // BULLET LIST BUILDER
  Widget _buildBulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6, right: 8),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF94A3B8),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  // SAFETY BADGE BUILDER
  Widget _buildSafeBadge(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.shade50.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.green.shade100,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_user_rounded,
            size: 15,
            color: Colors.green.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.green.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TACTILE CUSTOM CHECKBOX CARD
  Widget _buildCheckboxCard({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required Widget titleWidget,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: value ? Colors.blue.shade50.withOpacity(0.35) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? Colors.blue.shade500 : const Color(0xFFE2E8F0),
            width: value ? 1.5 : 1,
          ),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: Colors.blue.shade100.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 10),
              child: SizedBox(
                height: 18,
                width: 18,
                child: Checkbox(
                  value: value,
                  onChanged: onChanged,
                  activeColor: Colors.blue.shade600,
                  checkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Expanded(child: titleWidget),
          ],
        ),
      ),
    );
  }
}
