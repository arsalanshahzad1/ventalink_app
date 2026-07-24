import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/store/store_profile_controller.dart';
import 'package:ventalink_mobile/screens/store/onboarding/store_onboarding_screen.dart';
import 'package:ventalink_mobile/screens/store/store_shell.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';

/// Gate widget every store-role login/splash route lands on: decides whether
/// the merchant already has a Store (-> dashboard) or needs onboarding first.
class StoreEntryScreen extends StatefulWidget {
  const StoreEntryScreen({super.key});

  @override
  State<StoreEntryScreen> createState() => _StoreEntryScreenState();
}

class _StoreEntryScreenState extends State<StoreEntryScreen> {
  final storeProfileController = Get.find<StoreProfileController>();

  @override
  void initState() {
    super.initState();
    storeProfileController.loadMyStore();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!storeProfileController.hasChecked.value) {
        return const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (storeProfileController.store.value != null) {
        return const StoreShellScreen();
      }

      return const StoreOnboardingScreen();
    });
  }
}
