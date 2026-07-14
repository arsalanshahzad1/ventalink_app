import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/auth_controller.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/widgets/custom_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final authController = Get.find<AuthController>();
  bool hidePassword = true;
  bool hideConfirm = true;

  String? validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Full name is required';
    if (name.length < 2) return 'That name looks too short';
    return null;
  }

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    final atIndex = email.indexOf('@');
    if (atIndex <= 0 || atIndex != email.lastIndexOf('@')) return 'Enter a valid email';
    final domain = email.substring(atIndex + 1);
    if (!domain.contains('.') || domain.endsWith('.')) return 'Enter a valid email';
    return null;
  }

  String? validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return 'Phone number is required';
    if (phone.length < 7) return 'Enter a valid phone number';
    const allowedChars = '0123456789+- ()';
    for (final char in phone.split('')) {
      if (!allowedChars.contains(char)) return 'Enter a valid phone number';
    }
    return null;
  }

  bool hasUppercase(String value) {
    for (final char in value.split('')) {
      if (char != char.toLowerCase() && char == char.toUpperCase()) return true;
    }
    return false;
  }

  bool hasNumber(String value) {
    for (final char in value.split('')) {
      if ('0123456789'.contains(char)) return true;
    }
    return false;
  }

  bool hasSpecialChar(String value) {
    const specials = '!@#\$%^&*(),.?":{}|<>_-';
    for (final char in value.split('')) {
      if (specials.contains(char)) return true;
    }
    return false;
  }

  String? validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Password is required';
    if (password.length < 8) return 'Minimum 8 characters';
    if (!hasUppercase(password)) return 'Add at least 1 uppercase letter';
    if (!hasNumber(password)) return 'Add at least 1 number';
    if (!hasSpecialChar(password)) return 'Add at least 1 special character';
    return null;
  }

  String? validateConfirm(String? value) {
    if ((value ?? '').isEmpty) return 'Confirm your password';
    if (value != authController.signupPasswordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await authController.onSignUp();
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

  Widget accountTypeToggle() {
    return Obx(() {
      final selected = authController.accountType.value;
      Widget option(String value, String label) {
        final isSelected = selected == value;
        return Expanded(
          child: GestureDetector(
            onTap: () => authController.pickAccountType(value),
            child: Container(
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.textGrey,
                ),
              ),
            ),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            option('user', 'User'),
            const SizedBox(width: 4),
            option('merchant', 'Store'),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset("assets/images/logo-image.png", height: 60, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Create account",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Join VentaLink in a couple of minutes.",
                    style: TextStyle(fontSize: 14, color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 20),
                  accountTypeToggle(),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: authController.signupNameController,
                    decoration: fieldDecoration("Full name"),
                    validator: validateName,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: authController.signupEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: fieldDecoration("Email address"),
                    validator: validateEmail,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: authController.signupPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: fieldDecoration("Phone number"),
                    validator: validatePhone,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: authController.signupPasswordController,
                    obscureText: hidePassword,
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
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: authController.signupConfirmController,
                    obscureText: hideConfirm,
                    decoration: fieldDecoration(
                      "Confirm password",
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => hideConfirm = !hideConfirm),
                        icon: Icon(
                          hideConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ),
                    validator: validateConfirm,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    label: "Create account",
                    isLoading: authController.isSigningUp.value,
                    onPressed: submit,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: RichText(
                        text: const TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(color: AppColors.textGrey, fontSize: 14),
                          children: [
                            TextSpan(
                              text: "Log in",
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
    );
  }
}
