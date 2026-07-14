import 'dart:developer';

import 'package:get/get.dart';
import 'package:ventalink_mobile/models/notification_model.dart';
import 'package:ventalink_mobile/network/api_endpoints.dart';
import 'package:ventalink_mobile/network/api_service.dart';
import 'package:ventalink_mobile/utils/prompts.dart';

class NotificationsController extends GetxController {
  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;

  final Rx<AppNotification?> selected = Rx<AppNotification?>(null);
  final RxBool isLoadingDetail = false.obs;

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      final response = await Api().apiCall(ApiEndpoints.notifications, {"limit": 20}, null, RequestType.GET);

      response?.maybeWhen(
        success: (data) {
          final result = NotificationsResponse.fromJson(data);
          notifications.value = result.items;
          unreadCount.value = result.unreadCount;
        },
        error: (message, statusCode) {
          log("Error Returned with statusCode $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Loading notifications failed: $e");
    }
    isLoading.value = false;
  }

  Future<void> loadDetail(String id) async {
    isLoadingDetail.value = true;
    selected.value = null;

    try {
      final response = await Api().apiCall(ApiEndpoints.notificationDetail(id), null, null, RequestType.GET);

      response?.maybeWhen(
        success: (data) {
          selected.value = AppNotification.fromJson(data["notification"]);
        },
        error: (message, statusCode) {
          log("Error Returned with statusCode $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Loading notification detail failed: $e");
    }

    isLoadingDetail.value = false;

    if (selected.value != null && !selected.value!.isRead) {
      await markRead(id);
    }
  }

  Future<void> markRead(String id) async {
    try {
      await Api().apiCall(ApiEndpoints.markNotificationRead(id), null, {}, RequestType.POST);
      final index = notifications.indexWhere((item) => item.id == id);
      if (index != -1) {
        notifications[index].isRead = true;
        notifications.refresh();
        if (unreadCount.value > 0) unreadCount.value -= 1;
      }
      if (selected.value?.id == id) {
        selected.value!.isRead = true;
        selected.refresh();
      }
    } catch (e) {
      log("Marking notification read failed: $e");
    }
  }

  Future<void> markAllRead() async {
    try {
      await Api().apiCall(ApiEndpoints.markAllNotificationsRead, null, {}, RequestType.POST);
      for (final item in notifications) {
        item.isRead = true;
      }
      notifications.refresh();
      unreadCount.value = 0;
    } catch (e) {
      log("Marking all notifications read failed: $e");
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await Api().apiCall(ApiEndpoints.notificationDetail(id), null, null, RequestType.DELETE);
      notifications.removeWhere((item) => item.id == id);
    } catch (e) {
      log("Deleting notification failed: $e");
      Prompts.showSnackBar("Could not delete notification");
    }
  }

  Future<void> clearAll() async {
    try {
      await Api().apiCall(ApiEndpoints.clearNotifications, null, null, RequestType.DELETE);
      notifications.clear();
      unreadCount.value = 0;
    } catch (e) {
      log("Clearing notifications failed: $e");
      Prompts.showSnackBar("Could not clear notifications");
    }
  }
}
