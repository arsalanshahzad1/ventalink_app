import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/auth_controller.dart';
import 'package:ventalink_mobile/screens/legal/privacy_policy_screen.dart';
import 'package:ventalink_mobile/screens/legal/terms_and_conditions_screen.dart';
import 'package:ventalink_mobile/screens/store/loyalty/store_loyalty_screen.dart';
import 'package:ventalink_mobile/screens/store/settings/store_settings_screen.dart';
import 'package:ventalink_mobile/screens/store/share/store_share_screen.dart';
import 'package:ventalink_mobile/screens/store/transactions/store_transactions_screen.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/utils/routing_service.dart';

class StoreMoreScreen extends StatelessWidget {
  const StoreMoreScreen({super.key});

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textGrey, letterSpacing: 0.4)),
    );
  }

  Widget _tile({required IconData icon, required String title, required VoidCallback onTap, Color? color}) {
    final tileColor = color ?? AppColors.textDark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(icon, color: tileColor, size: 20),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: tileColor)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textGrey, size: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text("More", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionLabel("STORE"),
          _tile(icon: Icons.card_giftcard_outlined, title: "Loyalty program", onTap: () => RoutingService.push(const StoreLoyaltyScreen())),
          _tile(icon: Icons.history_outlined, title: "Transactions", onTap: () => RoutingService.push(const StoreTransactionsScreen())),
          _tile(icon: Icons.storefront_outlined, title: "Store settings", onTap: () => RoutingService.push(const StoreSettingsScreen())),
          _tile(icon: Icons.qr_code_outlined, title: "Share store", onTap: () => RoutingService.push(const StoreShareScreen())),
          _sectionLabel("LEGAL"),
          _tile(icon: Icons.description_outlined, title: "Terms & Conditions", onTap: () => RoutingService.push(const TermsAndConditionsScreen())),
          _tile(icon: Icons.privacy_tip_outlined, title: "Privacy Policy", onTap: () => RoutingService.push(const PrivacyPolicyScreen())),
          _sectionLabel("ACCOUNT"),
          _tile(icon: Icons.logout, title: "Log out", color: AppColors.error, onTap: authController.logOut),
        ],
      ),
    );
  }
}
