import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ventalink_mobile/models/user_model.dart';
import 'package:ventalink_mobile/network/api_endpoints.dart';
import 'package:ventalink_mobile/network/api_service.dart';
import 'package:ventalink_mobile/screens/auth/login_screen.dart';
import 'package:ventalink_mobile/screens/bottom_nav_screen.dart';
import 'package:ventalink_mobile/utils/common_utils.dart';
import 'package:ventalink_mobile/utils/prompts.dart';
import 'package:ventalink_mobile/utils/routing_service.dart';

class AuthController extends GetxController {
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final RxBool isLoggingIn = false.obs;

  final signupNameController = TextEditingController();
  final signupEmailController = TextEditingController();
  final signupPhoneController = TextEditingController();
  final signupPasswordController = TextEditingController();
  final signupConfirmController = TextEditingController();
  final RxString accountType = 'user'.obs;
  final RxBool isSigningUp = false.obs;

  final commonUtils = CommonUtils();

  void pickAccountType(String type) {
    accountType.value = type;
  }

  Future<void> onLogin() async {
    isLoggingIn.value = true;

    final body = {"email": loginEmailController.text.trim(), "password": loginPasswordController.text};

    try {
      final response = await Api().apiCall(ApiEndpoints.login, null, body, RequestType.POST);

      await response?.maybeWhen(
        success: (data) async {
          final userModel = UserModel.fromJson(data);
          if (userModel.user?.role == 'admin') {
            Prompts.showSnackBar("Admin can't access through mobile");
            return;
          }
          await commonUtils.saveSession(userModel);
          loginEmailController.clear();
          loginPasswordController.clear();
          RoutingService.pushAndRemoveUntil(const BottomNavScreen());
        },
        error: (message, statusCode) {
          Prompts.showSnackBar(message);
          log("Error Returned with statusCode $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Login failed: $e");
      Prompts.showSnackBar("Something went wrong, please try again");
    }

    isLoggingIn.value = false;
  }

  Future<void> onSignUp() async {
    isSigningUp.value = true;

    final body = {
      "fullName": signupNameController.text.trim(),
      "email": signupEmailController.text.trim(),
      "phone": signupPhoneController.text.trim(),
      "password": signupPasswordController.text,
      "role": accountType.value,
    };

    try {
      // log("signup payload :: () -> ${body}");
      final response = await Api().apiCall(ApiEndpoints.signUp, null, body, RequestType.POST);

      response?.maybeWhen(
        success: (data) {
          signupNameController.clear();
          signupEmailController.clear();
          signupPhoneController.clear();
          signupPasswordController.clear();
          signupConfirmController.clear();
          Prompts.showSnackBar("Account created, you can log in now");
          RoutingService.pushReplacement(const LoginScreen());
        },
        error: (message, statusCode) {
          Prompts.showSnackBar(message);
          log("Error Returned with statusCode $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Signup failed: $e");
      Prompts.showSnackBar("Something went wrong, please try again");
    }

    isSigningUp.value = false;
  }

  Future<void> logOut() async {
    try {
      await Api().apiCall(ApiEndpoints.logout, null, {}, RequestType.POST);
    } catch (e) {
      log("Logout call failed, clearing session locally anyway: $e");
    }

    await commonUtils.clearSession();
    RoutingService.pushAndRemoveUntil(const LoginScreen());
  }
}
