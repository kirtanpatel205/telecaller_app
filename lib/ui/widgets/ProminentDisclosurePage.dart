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
        "consent_required".tr,
        "please_accept_all_permissions_to_continue".tr,
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
          "failed_to_save_consent_please_try_again".tr,
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

    return AppSafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          titleText: "permission_disclosure".tr,
          showBackButton: false,
        ),
        body: WillPopScope(
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
                       Text(
                        "important_permission_disclosure_user_consent".tr,
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
                        "digi_bulk_marketing_employee_is_a_company_crm_and_customer_m".tr,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // CALL LOG SECTION
                      _buildSection(
                        title: "call_log_phone_information_access".tr,
                        content:
                            "this_app_collects_and_processes_call_information_such_as".tr,
                        items:  [
                          "phone_numbers".tr,
                          "call_duration".tr,
                          "call_type_incoming_outgoing_missed".tr,
                          "call_timestamp".tr,
                        ],
                      ),
                      const SizedBox(height: 12),

                      Text(
                        "this_information_is_used_only_for_business_crm_functionality".tr,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildBulletList( [
                        "identifying_customers_during_incoming_and_outgoing_calls".tr,
                        "displaying_customer_details_and_interaction_history_during_c".tr,
                        "automatically_linking_calls_with_customer_records".tr,
                        "tracking_employee_call_activity_and_performance_analytics".tr,
                        "maintaining_call_history_backup_across_authorized_devices".tr,
                        "supporting_order_creation_and_customer_follow_ups".tr,
                      ]),
                      const SizedBox(height: 12),

                      Text(
                        "the_app_does_not_record_call_audio_or_call_content".tr,
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
                        title: "write_call_log_access".tr,
                        content:
                            "the_app_may_create_or_update_call_interaction_entries_only_f".tr,
                        items:  [
                          "tagging_customer_calls".tr,
                          "linking_calls_to_customer_orders".tr,
                          "maintaining_business_interaction_history".tr,
                        ],
                      ),
                      const SizedBox(height: 12),

                      Text(
                        "the_app_does_not_delete_or_modify_personal_call_records_unre".tr,
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
                        title: "call_screening_overlay_display".tr,
                        content:
                            "the_app_uses_call_screening_and_overlay_permissions_to".tr,
                        items:  [
                          "detect_incoming_and_outgoing_calls".tr,
                          "show_customer_information_on_screen_during_calls".tr,
                          "allow_employees_to_quickly_create_orders_notes_or_crm_update".tr,
                        ],
                      ),
                      const SizedBox(height: 16),

                      // BACKGROUND SERVICE SECTION
                      _buildSection(
                        title: "background_service_device_restart".tr,
                        content:
                            "the_app_may_run_background_services_and_restart_after_device".tr,
                        items:  [
                          "continuous_call_detection".tr,
                          "crm_data_synchronization".tr,
                          "reliable_employee_productivity_tools".tr,
                        ],
                      ),
                      const SizedBox(height: 16),

                      // NOTIFICATIONS SECTION
                      _buildSection(
                        title: "NOTIFICATIONS",
                        content: "notification_permission_is_used_to".tr,
                        items:  [
                          "alert_employees_about_customer_calls".tr,
                          "provide_crm_reminders_and_business_updates".tr,
                        ],
                      ),
                      const SizedBox(height: 16),

                      // BATTERY OPTIMIZATION SECTION
                      _buildSection(
                        title: "battery_optimization_foreground_services".tr,
                        content:
                            "the_app_may_request_battery_optimization_exemption_and_foreg".tr,
                        items: const [],
                      ),
                      const SizedBox(height: 16),

                      // DATA USAGE & SECURITY SECTION
                      _buildSection(
                        title: "data_usage_security".tr,
                        content: "",
                        items:  [
                          "all_collected_information_is_used_only_for_employee_crm_and_".tr,
                          "data_is_securely_transmitted_to_company_servers".tr,
                          "data_is_not_sold_shared_with_third_parties_or_used_for_adver".tr,
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
                          "customer_interaction_data_is_securely_transmitted_to_nhttps_".tr,
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
                        title: "user_control".tr,
                        content: "",
                        items:  [
                          "permissions_are_requested_only_after_your_explicit_consent".tr,
                          "you_may_deny_or_revoke_permissions_anytime_from_device_setti".tr,
                          "if_permissions_are_denied_call_related_crm_features_and_call".tr,
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
                                "i_allow_digi_bulk_marketing_employee_to_access_call_log_and_".tr,
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
                                     TextSpan(text: "i_agree_to_the".tr),
                                    TextSpan(
                                      text: "terms_conditions".tr,
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
                                     TextSpan(text: "and".tr),
                                    TextSpan(
                                      text: "privacy_policy".tr,
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
                              "decline".tr,
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
                                    "i_agree".tr,
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
