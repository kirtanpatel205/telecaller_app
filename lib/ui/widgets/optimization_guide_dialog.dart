import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/core/services/background_service_manager.dart';
import 'package:telecaller_app/constants/app_colors.dart';

class OptimizationGuideDialog extends StatelessWidget {
  final bool isXiaomi;

  const OptimizationGuideDialog({super.key, required this.isXiaomi});

  static Future<void> showIfNeeded() async {
    // For now, let's just use a simple check. In a real app, you might use GetStorage
    // to show this only once.
    
    // We can't easily check isXiaomi here without the channel, 
    // but we can pass it from the caller.
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [AppColors.themeColor.primaryColor, AppColors.themeColor.primaryColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.battery_saver, color: Colors.white, size: 60),
            const SizedBox(height: 15),
            const Text(
              "Background Optimization",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isXiaomi
                  ? "Xiaomi/Redmi devices require extra steps to keep the service running 24/7. Please follow these steps:"
                  : "To ensure 24/7 reliability, please disable battery restrictions for this app.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 20),
            _buildStep(Icons.auto_awesome, "Enable 'Auto-start'"),
            _buildStep(Icons.battery_alert, "Set Battery Saver to 'No restrictions'"),
            _buildStep(Icons.lock, "Lock the app in Recent Apps (Padlock)"),
            _buildStep(Icons.window_rounded, "Enable 'Display pop-up windows while running in the background'"),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: const Text("LATER", style: TextStyle(color: Colors.white60)),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.themeColor.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Get.back();
                      if (isXiaomi) {
                        BackgroundServiceManager.optimizeForXiaomi();
                      } else {
                        BackgroundServiceManager.requestBatteryOptimization();
                      }
                    },
                    child: const Text("OPTIMIZE"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStep(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
