import 'dart:developer';

import 'package:get/get.dart';
import 'package:ventalink_mobile/models/store/merchant_product_model.dart';
import 'package:ventalink_mobile/network/api_endpoints.dart';
import 'package:ventalink_mobile/network/api_service.dart';
import 'package:ventalink_mobile/utils/prompts.dart';

class StoreProductsController extends GetxController {
  final RxList<MerchantProduct> products = <MerchantProduct>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString statusFilter = "all".obs;

  Future<void> loadProducts({String status = "all"}) async {
    statusFilter.value = status;
    isLoading.value = true;
    try {
      final response = await Api().apiCall(
        ApiEndpoints.products,
        {"status": status, "limit": 100},
        null,
        RequestType.GET,
      );

      response?.maybeWhen(
        success: (data) {
          products.value = MerchantProductResponse.fromJson(data).items;
        },
        error: (message, statusCode) {
          log("Error Returned with statusCode $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Loading products failed: $e");
    }
    isLoading.value = false;
  }

  Future<bool> createProduct(Map<String, dynamic> body) async {
    isSaving.value = true;
    bool success = false;

    try {
      final response = await Api().apiCall(ApiEndpoints.products, null, body, RequestType.POST);

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
      log("Creating product failed: $e");
      Prompts.showSnackBar("Could not create product");
    }

    if (success) await loadProducts(status: statusFilter.value);
    isSaving.value = false;
    return success;
  }

  Future<bool> updateProduct(String id, Map<String, dynamic> body) async {
    isSaving.value = true;
    bool success = false;

    try {
      final response = await Api().apiCall(ApiEndpoints.productDetail(id), null, body, RequestType.PATCH);

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
      log("Updating product failed: $e");
      Prompts.showSnackBar("Could not update product");
    }

    if (success) await loadProducts(status: statusFilter.value);
    isSaving.value = false;
    return success;
  }

  Future<bool> deleteProduct(String id) async {
    bool success = false;

    try {
      final response = await Api().apiCall(ApiEndpoints.productDetail(id), null, null, RequestType.DELETE);

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
      log("Deleting product failed: $e");
      Prompts.showSnackBar("Could not delete product");
    }

    if (success) products.removeWhere((product) => product.id == id);
    return success;
  }
}
