import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/auth_controller.dart';
import 'package:ventalink_mobile/models/user_model.dart';
import 'package:ventalink_mobile/screens/auth/login_screen.dart';
import 'package:ventalink_mobile/screens/legal/privacy_policy_screen.dart';
import 'package:ventalink_mobile/screens/legal/terms_and_conditions_screen.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/utils/common_utils.dart';
import 'package:ventalink_mobile/utils/prompts.dart';
import 'package:ventalink_mobile/utils/routing_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete account?", style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
          "This will remove your session and account details from this device. This action can't be undone.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Delete", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await CommonUtils().clearSession();
      Prompts.showSnackBar("Your account has been deleted");
      RoutingService.pushAndRemoveUntil(const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text("Profile", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: FutureBuilder<UserModel?>(
        future: CommonUtils().getSession(),
        builder: (context, snapshot) {
          final user = snapshot.data?.user;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
                child: Row(
                  children: [
                    Container(
                      height: 56,
                      width: 56,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
                      child: Text(
                        (user?.fullName?.isNotEmpty == true ? user!.fullName![0] : "?").toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user?.fullName ?? "—", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                          const SizedBox(height: 4),
                          Text(user?.email ?? "—", style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
                          if (user?.phone != null && user!.phone!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(user.phone!, style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _sectionLabel("LEGAL"),
              _tile(
                icon: Icons.description_outlined,
                title: "Terms & Conditions",
                onTap: () => RoutingService.push(const TermsAndConditionsScreen()),
              ),
              _tile(
                icon: Icons.privacy_tip_outlined,
                title: "Privacy Policy",
                onTap: () => RoutingService.push(const PrivacyPolicyScreen()),
              ),
              _sectionLabel("ACCOUNT"),
              _tile(icon: Icons.logout, title: "Log out", onTap: authController.logOut),
              _tile(
                icon: Icons.delete_outline,
                title: "Delete account",
                color: AppColors.error,
                onTap: () => _confirmDeleteAccount(context),
              ),
            ],
          );
        },
      ),
    );
  }
}
