import 'dart:developer';

import 'package:get/get.dart';
import 'package:ventalink_mobile/models/store/store_profile_model.dart';
import 'package:ventalink_mobile/network/api_endpoints.dart';
import 'package:ventalink_mobile/network/api_service.dart';

class StoreProfileController extends GetxController {
  final Rx<StoreProfile?> store = Rx<StoreProfile?>(null);
  final RxBool isLoading = false.obs;
  final RxBool storeMissing = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool hasChecked = false.obs;

  Future<void> loadMyStore() async {
    isLoading.value = true;
    try {
      final response = await Api().apiCall(ApiEndpoints.myStore, null, null, RequestType.GET);

      response?.maybeWhen(
        success: (data) {
          store.value = StoreProfile.fromJson(data["store"] ?? data);
          storeMissing.value = false;
        },
        error: (message, statusCode) {
          store.value = null;
          storeMissing.value = statusCode == 404;
          log("Error Returned with statusCode $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Loading store failed: $e");
      storeMissing.value = true;
    }
    hasChecked.value = true;
    isLoading.value = false;
  }

  Future<NetworkCallResult> createStore(Map<String, dynamic> body) async {
    isSaving.value = true;
    NetworkCallResult result = NetworkCallResult.failure("Something went wrong, please try again");

    try {
      final response = await Api().apiCall(ApiEndpoints.createStore, null, body, RequestType.POST);

      response?.maybeWhen(
        success: (data) {
          store.value = StoreProfile.fromJson(data["store"] ?? data);
          storeMissing.value = false;
          result = NetworkCallResult.success();
        },
        error: (message, statusCode) {
          log("Error Returned with statusCode $message $statusCode");
          result = NetworkCallResult.failure(message);
        },
        orElse: () {},
      );
    } catch (e) {
      log("Creating store failed: $e");
    }

    isSaving.value = false;
    return result;
  }

  Future<bool> updateStore(Map<String, dynamic> body) async {
    isSaving.value = true;
    bool success = false;

    try {
      final response = await Api().apiCall(ApiEndpoints.myStore, null, body, RequestType.PATCH);

      response?.maybeWhen(
        success: (data) {
          store.value = StoreProfile.fromJson(data["store"] ?? data);
          success = true;
        },
        error: (message, statusCode) {
          log("Error Returned with statusCode $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Updating store failed: $e");
    }

    isSaving.value = false;
    return success;
  }
}

class NetworkCallResult {
  final bool success;
  final String? message;

  NetworkCallResult._(this.success, this.message);

  factory NetworkCallResult.success() => NetworkCallResult._(true, null);
  factory NetworkCallResult.failure(String message) => NetworkCallResult._(false, message);
}
