import 'dart:developer';

import 'package:get/get.dart';
import 'package:ventalink_mobile/models/store/loyalty_model.dart';
import 'package:ventalink_mobile/network/api_endpoints.dart';
import 'package:ventalink_mobile/network/api_service.dart';
import 'package:ventalink_mobile/utils/prompts.dart';

class LoyaltyController extends GetxController {
  final Rx<LoyaltyProgram?> program = Rx<LoyaltyProgram?>(null);
  final RxList<LoyaltyCoupon> coupons = <LoyaltyCoupon>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingCoupons = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isRedeeming = false.obs;

  Future<void> loadProgram() async {
    isLoading.value = true;
    try {
      final response = await Api().apiCall(ApiEndpoints.loyaltyProgram, null, null, RequestType.GET);

      response?.maybeWhen(
        success: (data) {
          program.value = data["program"] == null ? null : LoyaltyProgram.fromJson(data["program"]);
        },
        error: (message, statusCode) {
          log("Error Returned with statusCode $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Loading loyalty program failed: $e");
    }
    isLoading.value = false;
  }

  Future<bool> upsertProgram(Map<String, dynamic> body) async {
    isSaving.value = true;
    bool success = false;

    try {
      final response = await Api().apiCall(ApiEndpoints.loyaltyProgram, null, body, RequestType.PATCH);

      response?.maybeWhen(
        success: (data) {
          program.value = LoyaltyProgram.fromJson(data["program"]);
          success = true;
          Prompts.showSnackBar("Loyalty program saved");
        },
        error: (message, statusCode) {
          Prompts.showSnackBar(message);
          log("Error Returned with statusCode $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Saving loyalty program failed: $e");
      Prompts.showSnackBar("Could not save loyalty program");
    }

    isSaving.value = false;
    return success;
  }

  Future<void> loadCoupons({String? status}) async {
    isLoadingCoupons.value = true;
    try {
      final response = await Api().apiCall(
        ApiEndpoints.loyaltyCoupons,
        status == null ? null : {"status": status},
        null,
        RequestType.GET,
      );

      response?.maybeWhen(
        success: (data) {
          coupons.value = (data["items"] as List? ?? []).map((item) => LoyaltyCoupon.fromJson(item)).toList();
        },
        error: (message, statusCode) {
          log("Error Returned with statusCode $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Loading coupons failed: $e");
    }
    isLoadingCoupons.value = false;
  }

  Future<bool> redeemCoupon(String code) async {
    isRedeeming.value = true;
    bool success = false;

    try {
      final response = await Api().apiCall(ApiEndpoints.redeemLoyaltyCoupon(code), null, {}, RequestType.POST);

      response?.maybeWhen(
        success: (data) {
          success = true;
          Prompts.showSnackBar("Coupon redeemed");
          loadCoupons();
        },
        error: (message, statusCode) {
          Prompts.showSnackBar(message);
          log("Error Returned with statusCode $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Redeeming coupon failed: $e");
      Prompts.showSnackBar("Could not redeem coupon");
    }

    isRedeeming.value = false;
    return success;
  }
}
