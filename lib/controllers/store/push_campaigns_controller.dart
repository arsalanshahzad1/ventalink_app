import 'dart:developer';
import 'dart:math' hide log;

import 'package:get/get.dart';
import 'package:ventalink_mobile/models/store/push_campaign_model.dart';
import 'package:ventalink_mobile/network/api_endpoints.dart';
import 'package:ventalink_mobile/network/api_service.dart';
import 'package:ventalink_mobile/utils/prompts.dart';

class PushCampaignsController extends GetxController {
  final RxList<PushCampaign> campaigns = <PushCampaign>[].obs;
  final Rx<PushEstimate?> estimate = Rx<PushEstimate?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isEstimating = false.obs;
  final RxBool isSubmitting = false.obs;

  Future<void> loadCampaigns({int limit = 20}) async {
    isLoading.value = true;
    try {
      final response = await Api().apiCall(ApiEndpoints.pushCampaigns, {"limit": limit}, null, RequestType.GET);

      response?.maybeWhen(
        success: (data) {
          campaigns.value = (data["items"] as List? ?? []).map((item) => PushCampaign.fromJson(item)).toList();
        },
        error: (message, statusCode) {
          log("Error Returned with statusCode $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Loading push campaigns failed: $e");
    }
    isLoading.value = false;
  }

  Future<void> estimateCampaign(Map<String, dynamic> payload) async {
    isEstimating.value = true;
    estimate.value = null;
    try {
      final response = await Api().apiCall(ApiEndpoints.pushCampaignEstimate, null, payload, RequestType.POST);

      response?.maybeWhen(
        success: (data) {
          estimate.value = PushEstimate.fromJson(data);
        },
        error: (message, statusCode) {
          Prompts.showSnackBar(message);
          log("Error Returned with statusCode $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Estimating push campaign failed: $e");
      Prompts.showSnackBar("Could not estimate campaign");
    }
    isEstimating.value = false;
  }

  Future<bool> createCampaign(Map<String, dynamic> payload) async {
    isSubmitting.value = true;
    bool success = false;

    final body = {
      ...payload,
      "idempotencyKey": "push-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1 << 32)}",
    };

    try {
      final response = await Api().apiCall(ApiEndpoints.pushCampaigns, null, body, RequestType.POST);

      response?.maybeWhen(
        success: (data) {
          success = true;
          Prompts.showSnackBar("Push campaign submitted");
        },
        error: (message, statusCode) {
          Prompts.showSnackBar(message);
          log("Error Returned with statusCode $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Creating push campaign failed: $e");
      Prompts.showSnackBar("Could not create push campaign");
    }

    if (success) {
      estimate.value = null;
      await loadCampaigns();
    }
    isSubmitting.value = false;
    return success;
  }
}
