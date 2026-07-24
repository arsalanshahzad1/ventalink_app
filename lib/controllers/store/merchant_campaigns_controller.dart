import 'dart:developer';

import 'package:get/get.dart';
import 'package:ventalink_mobile/models/store/merchant_campaign_model.dart';
import 'package:ventalink_mobile/network/api_endpoints.dart';
import 'package:ventalink_mobile/network/api_service.dart';
import 'package:ventalink_mobile/utils/prompts.dart';

class MerchantCampaignsController extends GetxController {
  final RxList<MerchantCampaign> campaigns = <MerchantCampaign>[].obs;
  final RxList<MerchantCampaignActivity> activity = <MerchantCampaignActivity>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingActivity = false.obs;
  final RxBool isSaving = false.obs;

  Future<void> loadCampaigns() async {
    isLoading.value = true;
    try {
      final response = await Api().apiCall(ApiEndpoints.merchantCampaigns, null, null, RequestType.GET);

      response?.maybeWhen(
        success: (data) {
          campaigns.value = (data["items"] as List? ?? []).map((item) => MerchantCampaign.fromJson(item)).toList();
        },
        error: (message, statusCode) {
          log("Error Returned with statusCode $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Loading campaigns failed: $e");
    }
    isLoading.value = false;
  }

  Future<void> loadActivity({int limit = 20}) async {
    isLoadingActivity.value = true;
    try {
      final response = await Api().apiCall(ApiEndpoints.merchantCampaignActivity, {"limit": limit}, null, RequestType.GET);

      response?.maybeWhen(
        success: (data) {
          activity.value = (data["items"] as List? ?? []).map((item) => MerchantCampaignActivity.fromJson(item)).toList();
        },
        error: (message, statusCode) {
          log("Error Returned with statusCode $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Loading campaign activity failed: $e");
    }
    isLoadingActivity.value = false;
  }

  Future<bool> createCampaign(Map<String, dynamic> body) async {
    isSaving.value = true;
    bool success = false;

    try {
      final response = await Api().apiCall(ApiEndpoints.merchantCampaigns, null, body, RequestType.POST);

      response?.maybeWhen(
        success: (data) {
          success = true;
        },
        error: (message, statusCode) {
          Prompts.showSnackBar(message);
          log("Error Returned with statusCode $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Creating campaign failed: $e");
      Prompts.showSnackBar("Could not create campaign");
    }

    if (success) await loadCampaigns();
    isSaving.value = false;
    return success;
  }

  Future<bool> updateCampaign(String id, Map<String, dynamic> body) async {
    isSaving.value = true;
    bool success = false;

    try {
      final response = await Api().apiCall(ApiEndpoints.merchantCampaignDetail(id), null, body, RequestType.PATCH);

      response?.maybeWhen(
        success: (data) {
          success = true;
        },
        error: (message, statusCode) {
          Prompts.showSnackBar(message);
          log("Error Returned with statusCode $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Updating campaign failed: $e");
      Prompts.showSnackBar("Could not update campaign");
    }

    if (success) await loadCampaigns();
    isSaving.value = false;
    return success;
  }
}
