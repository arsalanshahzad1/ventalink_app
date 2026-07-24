import 'dart:developer';

import 'package:get/get.dart';
import 'package:ventalink_mobile/models/order_model.dart';
import 'package:ventalink_mobile/network/api_endpoints.dart';
import 'package:ventalink_mobile/network/api_service.dart';

class StoreOrdersController extends GetxController {
  final RxList<OrderSummary> orders = <OrderSummary>[].obs;
  final RxBool isLoading = false.obs;
  final RxString statusFilter = "all".obs;

  final Rx<OrderSummary?> receiptOrder = Rx<OrderSummary?>(null);
  final Rx<OrderReceipt?> receipt = Rx<OrderReceipt?>(null);
  final RxBool isLoadingReceipt = false.obs;
  final RxBool receiptLoadFailed = false.obs;

  Future<void> loadOrders({String status = "all"}) async {
    statusFilter.value = status;
    isLoading.value = true;
    try {
      final response = await Api().apiCall(ApiEndpoints.sellerOrders, {"status": status}, null, RequestType.GET);

      response?.maybeWhen(
        success: (data) {
          orders.value = OrderSummaryResponse.fromJson(data).items;
        },
        error: (message, statusCode) {
          log("Error Returned with statusCode $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Loading seller orders failed: $e");
    }
    isLoading.value = false;
  }

  Future<void> loadReceipt(String orderId) async {
    isLoadingReceipt.value = true;
    receiptLoadFailed.value = false;
    receiptOrder.value = null;
    receipt.value = null;

    try {
      final response = await Api().apiCall(ApiEndpoints.orderReceipt(orderId), null, null, RequestType.GET);

      response?.maybeWhen(
        success: (data) {
          receiptOrder.value = OrderSummary.fromJson(data["order"]);
          receipt.value = OrderReceipt.fromJson(data["receipt"]);
        },
        error: (message, statusCode) {
          receiptLoadFailed.value = true;
          log("Error Returned with statusCode $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Loading receipt failed: $e");
      receiptLoadFailed.value = true;
    }

    isLoadingReceipt.value = false;
  }
}
