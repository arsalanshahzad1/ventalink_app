import 'dart:developer';

import 'package:get/get.dart';
import 'package:ventalink_mobile/models/order_model.dart';
import 'package:ventalink_mobile/network/api_endpoints.dart';
import 'package:ventalink_mobile/network/api_service.dart';

class TrackOrderController extends GetxController {
  final RxList<OrderSummary> results = <OrderSummary>[].obs;
  final RxBool isSearching = false.obs;
  final RxBool hasSearched = false.obs;

  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return;

    isSearching.value = true;
    hasSearched.value = true;

    try {
      final response = await Api().apiCall(ApiEndpoints.orderLookup, {"q": trimmed}, null, RequestType.GET);

      response?.maybeWhen(
        success: (data) {
          results.value = (data["items"] as List).map((item) => OrderSummary.fromJson(item)).toList();
        },
        error: (message, statusCode) {
          results.clear();
          log("Error Returned with statusCode $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Order lookup failed: $e");
      results.clear();
    }

    isSearching.value = false;
  }
}
