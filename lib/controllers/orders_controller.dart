import 'dart:developer';

import 'package:get/get.dart';
import 'package:ventalink_mobile/models/order_model.dart';
import 'package:ventalink_mobile/network/api_endpoints.dart';
import 'package:ventalink_mobile/network/api_service.dart';

class OrdersController extends GetxController {
  final RxList<OrderSummary> purchaseHistory = <OrderSummary>[].obs;
  final RxBool isLoadingHistory = false.obs;

  final Rx<OrderSummary?> receiptOrder = Rx<OrderSummary?>(null);
  final Rx<OrderReceipt?> receipt = Rx<OrderReceipt?>(null);
  final RxBool isLoadingReceipt = false.obs;
  final RxBool receiptLoadFailed = false.obs;

  Future<void> loadPurchaseHistory() async {
    isLoadingHistory.value = true;
    try {
      final response = await Api().apiCall(ApiEndpoints.myPurchaseHistory, {"status": "paid,pending"}, null, RequestType.GET);

      response?.maybeWhen(
        success: (data) {
          purchaseHistory.value = OrderSummaryResponse.fromJson(data).items;
        },
        error: (message, statusCode) {
          log("Error Returned with statusCode $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Loading purchase history failed: $e");
    }
    isLoadingHistory.value = false;
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
