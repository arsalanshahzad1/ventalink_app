import 'package:flutter/material.dart';
import 'package:ventalink_mobile/screens/auth/login_screen.dart';
import 'package:ventalink_mobile/screens/bottom_nav_screen.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/utils/common_utils.dart';
import 'package:ventalink_mobile/utils/routing_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), goNext);
  }

  Future<void> goNext() async {
    final session = await CommonUtils().getSession();
    if (session != null) {
      RoutingService.pushAndRemoveUntil(const BottomNavScreen());
    } else {
      RoutingService.pushAndRemoveUntil(const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset("assets/images/logo-image.png", width: 240, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
