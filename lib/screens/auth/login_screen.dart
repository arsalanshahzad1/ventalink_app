import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/auth_controller.dart';
import 'package:ventalink_mobile/screens/auth/signup_screen.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/utils/routing_service.dart';
import 'package:ventalink_mobile/widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final authController = Get.find<AuthController>();
  bool hidePassword = true;

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    final atIndex = email.indexOf('@');
    if (atIndex <= 0 || atIndex != email.lastIndexOf('@')) return 'Enter a valid email';
    final domain = email.substring(atIndex + 1);
    if (!domain.contains('.') || domain.endsWith('.')) return 'Enter a valid email';
    return null;
  }

  String? validatePassword(String? value) {
    if ((value ?? '').isEmpty) return 'Password is required';
    return null;
  }

  Future<void> submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await authController.onLogin();
  }

  InputDecoration fieldDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textGrey),
      filled: true,
      fillColor: AppColors.white,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset("assets/images/logo-image.png", height: 60, fit: BoxFit.cover),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Log in",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.textDark),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Pick up where you left off.",
                  style: TextStyle(fontSize: 14, color: AppColors.textGrey),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextFormField(
                              controller: authController.loginEmailController,
                              keyboardType: TextInputType.emailAddress,
                              // textAlign: TextAlign.center,
                              decoration: fieldDecoration("Email address"),
                              validator: validateEmail,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: authController.loginPasswordController,
                              obscureText: hidePassword,
                              // textAlign: TextAlign.center,
                              decoration: fieldDecoration(
                                "Password",
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => hidePassword = !hidePassword),
                                  icon: Icon(
                                    hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              ),
                              validator: validatePassword,
                            ),
                            const SizedBox(height: 24),
                            CustomButton(
                              label: "Log in",
                              isLoading: authController.isLoggingIn.value,
                              onPressed: submit,
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: GestureDetector(
                                onTap: () => RoutingService.push(const SignUpScreen()),
                                child: RichText(
                                  text: const TextSpan(
                                    text: "New here? ",
                                    style: TextStyle(color: AppColors.textGrey, fontSize: 14),
                                    children: [
                                      TextSpan(
                                        text: "Create an account",
                                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
