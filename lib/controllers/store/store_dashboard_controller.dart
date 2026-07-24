import 'dart:developer';

import 'package:get/get.dart';
import 'package:ventalink_mobile/models/store/dashboard_metrics_model.dart';
import 'package:ventalink_mobile/network/api_endpoints.dart';
import 'package:ventalink_mobile/network/api_service.dart';

class StoreDashboardController extends GetxController {
  final Rx<DashboardMetrics?> metrics = Rx<DashboardMetrics?>(null);
  final RxBool isLoading = false.obs;

  Future<void> loadMetrics() async {
    isLoading.value = true;
    try {
      final response = await Api().apiCall(ApiEndpoints.dashboardMetrics, null, null, RequestType.GET);

      response?.maybeWhen(
        success: (data) {
          metrics.value = DashboardMetrics.fromJson(data);
        },
        error: (message, statusCode) {
          log("Error Returned with statusCode $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Loading dashboard metrics failed: $e");
    }
    isLoading.value = false;
  }
}
