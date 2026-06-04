import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get_storage/get_storage.dart';
import 'package:telecaller_app/constants/app_constants.dart';
import 'package:telecaller_app/constants/app_routes.dart';
import 'package:telecaller_app/core/helpers/storage.dart';
import 'package:telecaller_app/core/services/background_service_manager.dart';
import 'package:telecaller_app/core/services/fcm_service.dart';
import 'package:telecaller_app/core/services/phone_status_service.dart';
import 'package:telecaller_app/constants/app_colors.dart';
import 'package:telecaller_app/main.dart';
import 'app_safe_area.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'optimization_guide_dialog.dart';
import 'custom-appbar.dart';

class PermissionStatusScreen extends StatefulWidget {
  @override
  State<PermissionStatusScreen> createState() => _PermissionStatusScreenState();
}

class _PermissionStatusScreenState extends State<PermissionStatusScreen>
    with SingleTickerProviderStateMixin {
  Map<String, PermissionStatus> permissionStatuses = {};
  bool isLoading = true;
  bool isContinuing = false;
  bool isXiaomi = false;
  static const _channel = MethodChannel(
    'com.digibulkmarketing.telecaller_app/lockscreen',
  );
  late AnimationController _animationController;

  final Map<String, List<Permission>> permissionGroups = {
    'Phone & Call': [Permission.phone],
    'Notifications': [Permission.notification],
    'Location & Media': [Permission.location, Permission.camera],
    'System & Overlay': [
      Permission.systemAlertWindow,
      Permission.ignoreBatteryOptimizations,
    ],
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _checkDeviceAndPermissions();
  }

  Future<void> _checkDeviceAndPermissions() async {
    try {
      if (Platform.isAndroid) {
        final bool result = await _channel.invokeMethod('isXiaomi');
        setState(() => isXiaomi = result);

        if (isXiaomi) {
          setState(() {
            permissionGroups['Manufacturer Optimization'] = [];
          });
        }
      }
    } catch (e) {
      print("Error checking device type: $e");
    }
    _checkAllPermissions();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ✅ ADDED: Battery optimization exclusion method
  static Future<void> requestBatteryOptimizationExclusion() async {
    if (Platform.isAndroid) {
      var status = await Permission.ignoreBatteryOptimizations.status;
      if (status.isDenied) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    }
  }

  Future<void> _savePermissionsToStorage() async {
    try {
      final permMap = <String, String>{};
      permissionStatuses.forEach((name, status) {
        permMap[name] = status.toString();
      });
      await Storage.saveValue('permissions_status', permMap);
      print("permissions_saved_to_storage".tr);
    } catch (e) {
      print("❌ Error saving permissions: $e");
    }
  }

  Future<void> _checkAllPermissions() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    permissionStatuses = {};

    for (var group in permissionGroups.values) {
      for (var permission in group) {
        try {
          final status = await permission.status;
          final permName = permission.toString().split('.').last;
          permissionStatuses[permName] = status;
        } catch (e) {
          print("❌ Error checking permission: $e");
        }
      }
    }

    await _savePermissionsToStorage();

    if (!mounted) return;
    setState(() => isLoading = false);
    _animationController.forward();
  }

  String _getPermissionTitle(String permName) {
    switch (permName) {
      case 'phone':
        return 'Phone Access';
      case 'callLog':
        return 'Call History';
      case 'notification':
        return 'Notifications';
      case 'location':
        return 'Location';
      case 'camera':
        return 'Camera & Media';
      case 'storage':
        return 'Storage Access';
      case 'systemAlertWindow':
        return 'Screen Alerts';
      case 'ignoreBatteryOptimizations':
        return 'Background Running';
      default:
        return 'Permission';
    }
  }

  String _getPermissionDescription(String permName) {
    switch (permName) {
      case 'phone':
        return 'Show caller ID information';
      case 'callLog':
        return 'Access call history and logs';
      case 'notification':
        return 'Alert you about blocked calls';
      case 'location':
        return 'Fetch current location for forms';
      case 'camera':
        return 'Capture photos and videos';
      case 'storage':
        return 'Access files and media';
      case 'systemAlertWindow':
        return 'Display floating alerts';
      case 'ignoreBatteryOptimizations':
        return 'Run protection 24/7';
      default:
        return 'Permission access';
    }
  }

  bool _isSensitivePermission(String permName) {
    return permName == 'callLog' || permName == 'phone';
  }

  IconData _getLeadingIcon(String permName) {
    switch (permName) {
      case 'phone':
        return Icons.phone_in_talk_rounded;
      case 'callLog':
        return Icons.history_rounded;
      case 'notification':
        return Icons.notifications_active_rounded;
      case 'location':
        return Icons.location_on_rounded;
      case 'camera':
        return Icons.camera_alt_rounded;
      case 'storage':
        return Icons.folder_rounded;
      case 'systemAlertWindow':
        return Icons.layers_rounded;
      case 'ignoreBatteryOptimizations':
        return Icons.bolt_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  Future<void> _showSensitivePermissionDialog(Permission permission) async {
    final permName = permission.toString().split('.').last;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.security_rounded, color: Colors.orange, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Sensitive Permission',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Why we need this:',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _getPermissionDescription(permName),
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.themeColor.primaryColor.withOpacity(0.1),
                          AppColors.themeColor.primaryColor.withOpacity(0.2)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.themeColor.primaryColor.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lock_rounded,
                              color: AppColors.themeColor.primaryColor,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Your Privacy is Protected',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.themeColor.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          '✓ Encrypted and secure\n'
                          '✓ Used only for spam blocking\n'
                          '✓ Never sold to third parties\n'
                          '✓ Revoke anytime in settings',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.themeColor.primaryColor,
                            fontWeight: FontWeight.w500,
                            height: 1.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Not Now',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _requestPermission(permission);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.themeColor.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Allow Access',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _requestPermission(Permission permission) async {
    try {
      final status = await permission.request();
      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
      await _checkAllPermissions();
    } catch (e) {
      print("❌ Permission request error: $e");
    }
  }

  Future<void> _requestAllPermissions() async {
    try {
      // ✅ ADDED: Request battery optimization exclusion first
      await requestBatteryOptimizationExclusion();

      final allPermissions = <Permission>[];
      for (var group in permissionGroups.values) {
        allPermissions.addAll(group);
      }

      final uniquePermissions = allPermissions.toSet().toList();

      for (var permission in uniquePermissions) {
        try {
          final permName = permission.toString().split('.').last;

          // ✅ Skip ignoreBatteryOptimizations here since already handled above
          if (permName == 'ignoreBatteryOptimizations') continue;

          if (_isSensitivePermission(permName)) {
            await _showSensitivePermissionDialog(permission);
          } else {
            await permission.request();
          }
          await Future.delayed(Duration(milliseconds: 300));
        } catch (e) {
          print("⚠️ Could not request $permission: $e");
        }
      }

      await _checkAllPermissions();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Permission request completed'),
          backgroundColor: AppColors.themeColor.primaryColor,
          duration: Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      print("❌ Error requesting all permissions: $e");
    }
  }

  int _getGrantedCount() {
    int count = 0;
    permissionStatuses.forEach((_, status) {
      if (status.isGranted) count++;
    });
    return count;
  }

  bool _areAllPermissionsGranted() {
    return _getGrantedCount() == permissionStatuses.length &&
        permissionStatuses.isNotEmpty;
  }

  Future<void> _continueToWelcome() async {
    if (isContinuing) return;

    if (!mounted) return;
    setState(() => isContinuing = true);

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => WillPopScope(
              onWillPop: () async => false,
              child: Dialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.themeColor.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Setting up...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      );

      await Storage.saveValue('permissions_shown', true);
      await Storage.saveValue('notification_setup', true);
      await Storage.saveValue('backgroundService_setup', true);

      // ✅ Ensure SIM info is fetched and cached before starting the service
      if (await Permission.phone.isGranted) {
        await BackgroundServiceManager.fetchAndSaveSimInfo();
      }

      // ✅ ADDED: Also ensure battery optimization is excluded during setup
      await requestBatteryOptimizationExclusion();

      try {
        await BackgroundServiceManager.initializeService();
        logger.i("background_service_initialized".tr);
      } catch (e) {
        logger.e("❌ Background service error: $e");
      }

      await Future.delayed(Duration(seconds: 2));

      final service = FlutterBackgroundService();
      final isServiceRunning = await service.isRunning();

      print("🔍 BackgroundService running status: $isServiceRunning");

      if (isServiceRunning) {
        try {
          await Future.delayed(Duration(milliseconds: 500));

          print("triggering_syncnow".tr);
          service.invoke("syncNow");
          print("syncnow_triggered".tr);
        } catch (e) {
          print("❌ BackgroundService invoke error: $e");
        }
      } else {
        print("backgroundservice_is_not_running".tr);
      }

      try {
        await Get.put<FCMService>(FCMService()).init();

        // ✅ ADDED: Initialize PhoneStatusService once permissions are granted
        if (!Get.isRegistered<PhoneStatusService>()) {
          await Get.putAsync<PhoneStatusService>(
            () async => await PhoneStatusService().init(),
            permanent: true,
          );
          print("phonestatusservice_initialized_in_permissionscreen".tr);
        }
      } catch (e) {
        print("⚠️ Service initialization error: $e");
      }

      await Future.delayed(Duration(milliseconds: 1000));

      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      print("❌ Error in continue: $e");

      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        setState(() => isContinuing = false);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Setup failed. Please try again.'),
            backgroundColor: Colors.red.shade600,
            duration: Duration(seconds: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !isContinuing,
      child: AppSafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(
            titleText: 'Permissions',
            actions: [
              IconButton(
                icon: Icon(Icons.refresh_rounded, size: 24.sp),
                onPressed: isLoading ? null : _checkAllPermissions,
                tooltip: 'Refresh',
                splashRadius: 24,
              ),
            ],
            showBackButton: false,
          ),
          body:
              isLoading
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.themeColor.primaryColor,
                          ),
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Checking permissions...',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                  : FadeTransition(
                    opacity: _animationController,
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        100,
                      ), // Extra bottom padding for the floating button
                      children: [
                        // ── Setup Status Card ──────────────────────────
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.themeColor.primaryColor.withOpacity(0.1),
                                AppColors.themeColor.primaryColor.withOpacity(0.2),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.themeColor.primaryColor.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Setup Status',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '${_getGrantedCount()}/${permissionStatuses.length} Active',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.themeColor.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.themeColor.primaryColor.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      '${(((_getGrantedCount() / (permissionStatuses.isEmpty ? 1 : permissionStatuses.length)) * 100).toInt())}%',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.themeColor.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: LinearProgressIndicator(
                                  value:
                                      permissionStatuses.isEmpty
                                          ? 0
                                          : _getGrantedCount() /
                                              permissionStatuses.length,
                                  minHeight: 12,
                                  backgroundColor: Colors.white,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.themeColor.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── Permission Groups ──────────────────────────
                        ...permissionGroups.entries.map((entry) {
                          final groupName = entry.key;
                          final permissions = entry.value;

                          if (groupName == 'Manufacturer Optimization' &&
                              isXiaomi) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(8, 24, 8, 12),
                                  child: Text(
                                    groupName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.orange.shade700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                PermissionCard(
                                  title: 'Auto-start Settings',
                                  description:
                                      'Allow app to start automatically on reboot',
                                  icon: Icons.tips_and_updates_rounded,
                                  isGranted:
                                      Storage.getValue(
                                        'manufacturer_optimization_shown',
                                      ) ??
                                      false,
                                  onTap: () async {
                                    await BackgroundServiceManager.openManufacturerSettings();
                                    await Storage.saveValue(
                                      'manufacturer_optimization_shown',
                                      true,
                                    );
                                    _checkAllPermissions();
                                  },
                                ),
                              ],
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(8, 24, 8, 12),
                                child: Text(
                                  groupName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              ...permissions.map((permission) {
                                final permName =
                                    permission.toString().split('.').last;
                                final status =
                                    permissionStatuses[permName] ??
                                    PermissionStatus.denied;

                                return Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: PermissionCard(
                                    title: _getPermissionTitle(permName),
                                    description: _getPermissionDescription(
                                      permName,
                                    ),
                                    icon: _getLeadingIcon(permName),
                                    isGranted: status.isGranted,
                                    onTap:
                                        status.isDenied ||
                                                status.isPermanentlyDenied
                                            ? () {
                                              if (_isSensitivePermission(
                                                permName,
                                              )) {
                                                _showSensitivePermissionDialog(
                                                  permission,
                                                );
                                              } else {
                                                _requestPermission(permission);
                                              }
                                            }
                                            : null,
                                  ),
                                );
                              }).toList(),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                height: 56,
                child:
                    _areAllPermissionsGranted()
                        ? ElevatedButton.icon(
                          onPressed: isContinuing ? null : _continueToWelcome,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.themeColor.primaryColor,
                            disabledBackgroundColor: AppColors.themeColor.primaryColor.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 4,
                          ),
                          icon:
                              isContinuing
                                  ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : Icon(Icons.check_circle_rounded, size: 24),
                          label: Text(
                            isContinuing ? 'Setting up...' : 'Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        )
                        : ElevatedButton.icon(
                          onPressed: isLoading ? null : _requestAllPermissions,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.themeColor.primaryColor,
                            disabledBackgroundColor: AppColors.themeColor.primaryColor.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 4,
                          ),
                          icon: Icon(Icons.shield_rounded, size: 24),
                          label: Text(
                            'Enable All',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PermissionCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isGranted;
  final VoidCallback? onTap;

  const PermissionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isGranted,
    this.onTap,
  });

  @override
  State<PermissionCard> createState() => _PermissionCardState();
}

class _PermissionCardState extends State<PermissionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapController;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onTap != null) {
          _tapController.forward();
        }
      },
      onTapUp: (_) {
        if (widget.onTap != null) {
          _tapController.reverse();
          widget.onTap?.call();
        }
      },
      onTapCancel: () {
        if (widget.onTap != null) {
          _tapController.reverse();
        }
      },
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.98).animate(
          CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
        ),
        child: Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  widget.isGranted
                      ? AppColors.themeColor.primaryColor.withOpacity(0.5)
                      : Colors.grey.shade200,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      widget.isGranted
                          ? AppColors.themeColor.primaryColor.withOpacity(0.1)
                          : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.icon,
                  color:
                      widget.isGranted
                          ? AppColors.themeColor.primaryColor
                          : Colors.grey.shade600,
                  size: 24,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              if (widget.isGranted)
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.themeColor.primaryColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: AppColors.themeColor.primaryColor,
                    size: 20,
                  ),
                )
              else
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: Colors.grey.shade600,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
