import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/notifications_controller.dart';
import 'package:ventalink_mobile/models/notification_model.dart';
import 'package:ventalink_mobile/screens/notifications/notification_detail_screen.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/utils/formatters.dart';
import 'package:ventalink_mobile/utils/routing_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  IconData _iconFor(String kind) {
    switch (kind) {
      case "order":
        return Icons.inventory_2_outlined;
      case "wallet":
      case "reward":
        return Icons.account_balance_wallet_outlined;
      case "receipt":
        return Icons.receipt_long_outlined;
      case "store":
        return Icons.storefront_outlined;
      case "gift":
        return Icons.card_giftcard_outlined;
      case "account":
        return Icons.person_add_alt_outlined;
      default:
        return Icons.shield_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationsController = Get.find<NotificationsController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text("Notifications", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
        actions: [
          TextButton(
            onPressed: notificationsController.markAllRead,
            child: const Text("Mark all read", style: TextStyle(color: AppColors.primary, fontSize: 12)),
          ),
          IconButton(
            onPressed: notificationsController.clearAll,
            icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.textGrey),
          ),
        ],
      ),
      body: Obx(() {
        if (notificationsController.isLoading.value && notificationsController.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (notificationsController.notifications.isEmpty) {
          return const Center(
            child: Text("You're all caught up.", style: TextStyle(color: AppColors.textGrey)),
          );
        }

        return RefreshIndicator(
          onRefresh: notificationsController.loadNotifications,
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: notificationsController.notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final AppNotification item = notificationsController.notifications[index];

              return Dismissible(
                key: ValueKey(item.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                onDismissed: (_) => notificationsController.deleteNotification(item.id),
                child: GestureDetector(
                  onTap: () => RoutingService.push(NotificationDetailScreen(notificationId: item.id)),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: item.isRead ? AppColors.border : AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 38,
                          width: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(_iconFor(item.kind), size: 18, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              const SizedBox(height: 2),
                              Text(
                                item.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                              ),
                              const SizedBox(height: 4),
                              Text(timeAgo(item.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                            ],
                          ),
                        ),
                        if (!item.isRead)
                          Container(
                            margin: const EdgeInsets.only(top: 4, left: 6),
                            height: 8,
                            width: 8,
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
