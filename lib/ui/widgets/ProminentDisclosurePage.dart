import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/core/helpers/storage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_routes.dart';

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
        Get.offAllNamed(Routes.LOGIN);
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Permission Disclosure",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Column(
            children: [
              // SCROLLABLE CONTENT AREA
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main Title
                      const Text(
                        "Important Permission Disclosure & User Consent",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Description Text
                      Text(
                        "Digi Bulk Marketing – Employee is a company CRM and customer "
                        "management application designed for registered employees. "
                        "To provide its core business features, this app requires access "
                        "to certain phone and system permissions.",
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // CALL LOG SECTION
                      _buildSection(
                        title: "CALL LOG & PHONE INFORMATION ACCESS",
                        content:
                            "This app collects and processes call information such as:",
                        items: const [
                          "Phone numbers",
                          "Call duration",
                          "Call type (incoming, outgoing, missed)",
                          "Call timestamp",
                        ],
                      ),
                      const SizedBox(height: 12),

                      Text(
                        "This information is used only for business CRM functionality, including:",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildBulletList(const [
                        "Identifying customers during incoming and outgoing calls",
                        "Displaying customer details and interaction history during calls",
                        "Automatically linking calls with customer records",
                        "Tracking employee call activity and performance analytics",
                        "Maintaining call history backup across authorized devices",
                        "Supporting order creation and customer follow-ups",
                      ]),
                      const SizedBox(height: 12),

                      Text(
                        "The app does NOT record call audio or call content.",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.green.shade700,
                          backgroundColor: Colors.green.shade50,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // WRITE CALL LOG SECTION
                      _buildSection(
                        title: "WRITE CALL LOG ACCESS",
                        content:
                            "The app may create or update call interaction entries only for CRM tracking purposes such as:",
                        items: const [
                          "Tagging customer calls",
                          "Linking calls to customer orders",
                          "Maintaining business interaction history",
                        ],
                      ),
                      const SizedBox(height: 12),

                      Text(
                        "The app does NOT delete or modify personal call records unrelated to company CRM usage.",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.green.shade700,
                          backgroundColor: Colors.green.shade50,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // CALL SCREENING SECTION
                      _buildSection(
                        title: "CALL SCREENING & OVERLAY DISPLAY",
                        content:
                            "The app uses call screening and overlay permissions to:",
                        items: const [
                          "Detect incoming and outgoing calls",
                          "Show customer information on screen during calls",
                          "Allow employees to quickly create orders, notes, or CRM updates without interrupting calls",
                        ],
                      ),
                      const SizedBox(height: 16),

                      // BACKGROUND SERVICE SECTION
                      _buildSection(
                        title: "BACKGROUND SERVICE & DEVICE RESTART",
                        content:
                            "The app may run background services and restart after device reboot to ensure:",
                        items: const [
                          "Continuous call detection",
                          "CRM data synchronization",
                          "Reliable employee productivity tools",
                        ],
                      ),
                      const SizedBox(height: 16),

                      // NOTIFICATIONS SECTION
                      _buildSection(
                        title: "NOTIFICATIONS",
                        content: "Notification permission is used to:",
                        items: const [
                          "Alert employees about customer calls",
                          "Provide CRM reminders and business updates",
                        ],
                      ),
                      const SizedBox(height: 16),

                      // BATTERY OPTIMIZATION SECTION
                      _buildSection(
                        title: "BATTERY OPTIMIZATION & FOREGROUND SERVICES",
                        content:
                            "The app may request battery optimization exemption and foreground service permissions "
                            "to maintain reliable real-time call detection and CRM syncing.",
                        items: const [],
                      ),
                      const SizedBox(height: 16),

                      // DATA USAGE & SECURITY SECTION
                      _buildSection(
                        title: "DATA USAGE & SECURITY",
                        content: "",
                        items: const [
                          "All collected information is used only for employee CRM and business communication features",
                          "Data is securely transmitted to company servers",
                          "Data is NOT sold, shared with third parties, or used for advertising",
                        ],
                      ),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.shade200,
                          ),
                        ),
                        child: Text(
                          "Customer interaction data is securely transmitted to:\nhttps://master.digibulkmarketing.com",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade900,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // USER CONTROL SECTION
                      _buildSection(
                        title: "USER CONTROL",
                        content: "",
                        items: const [
                          "Permissions are requested only after your explicit consent",
                          "You may deny or revoke permissions anytime from device settings",
                          "If permissions are denied, call-related CRM features and caller identification may not function",
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // FIXED BOTTOM SECTION WITH PROPER SPACING
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // CALL LOG CHECKBOX - PROPER ALIGNMENT
                    InkWell(
                      onTap: () {
                        setState(() {
                          acceptCallLog = !acceptCallLog;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // CHECKBOX
                            Padding(
                              padding: const EdgeInsets.only(top: 2, right: 12),
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: acceptCallLog,
                                  onChanged: (v) {
                                    setState(() {
                                      acceptCallLog = v ?? false;
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                            // CHECKBOX TEXT
                            Expanded(
                              child: Text(
                                "I allow Digi Bulk Marketing – Employee to access Call Log and Phone information for CRM and call management features.",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade800,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // TERMS & PRIVACY CHECKBOX - PROPER ALIGNMENT
                    InkWell(
                      onTap: () {
                        setState(() {
                          acceptTermsPrivacy = !acceptTermsPrivacy;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // CHECKBOX
                            Padding(
                              padding: const EdgeInsets.only(top: 2, right: 12),
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                    value: acceptTermsPrivacy,
                                    onChanged: (v) {
                                      setState(() {
                                        acceptTermsPrivacy = v ?? false;
                                      });
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    )),
                              ),
                            ),
                            // RICH TEXT FOR LINKS
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade800,
                                    height: 1.4,
                                  ),
                                  children: [
                                    const TextSpan(text: "I agree to the "),
                                    TextSpan(
                                      text: "Terms & Conditions",
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600,
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
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600,
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
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ACTION BUTTONS
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isProcessing ? null : _decline,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(
                                color: isProcessing
                                    ? Colors.grey.shade300
                                    : Colors.red.shade400,
                              ),
                            ),
                            child: Text(
                              "Decline",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isProcessing
                                    ? Colors.grey.shade400
                                    : Colors.red.shade400,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: (acceptCallLog &&
                                    acceptTermsPrivacy &&
                                    !isProcessing)
                                ? _agree
                                : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.green.shade600,
                              disabledBackgroundColor: Colors.grey.shade300,
                            ),
                            child: isProcessing
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    "I Agree",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
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
        ),
      ),
    );
  }

// HELPER WIDGET FOR SECTIONS
  Widget _buildSection({
    required String title,
    required String content,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            letterSpacing: 0.3,
          ),
        ),
        if (content.isNotEmpty) const SizedBox(height: 8),
        if (content.isNotEmpty)
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        if (items.isNotEmpty) const SizedBox(height: 8),
        if (items.isNotEmpty) _buildBulletList(items),
      ],
    );
  }

// HELPER WIDGET FOR BULLET LISTS
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
                    padding: const EdgeInsets.only(top: 5, right: 8),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade600,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.5,
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
}
