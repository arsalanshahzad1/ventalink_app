import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/notifications_controller.dart';
import 'package:ventalink_mobile/screens/receipts/receipt_detail_screen.dart';
import 'package:ventalink_mobile/screens/wallet/transactions_screen.dart';
import 'package:ventalink_mobile/screens/wallet/wallet_screen.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/utils/formatters.dart';
import 'package:ventalink_mobile/utils/prompts.dart';
import 'package:ventalink_mobile/utils/routing_service.dart';
import 'package:ventalink_mobile/widgets/gradient_button.dart';

class NotificationDetailScreen extends StatefulWidget {
  final String notificationId;

  const NotificationDetailScreen({super.key, required this.notificationId});

  @override
  State<NotificationDetailScreen> createState() => _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  final notificationsController = Get.find<NotificationsController>();

  @override
  void initState() {
    super.initState();
    notificationsController.loadDetail(widget.notificationId);
  }

  void _openRelatedPage(String destination) {
    if (destination.contains("digital-receipt/")) {
      final orderId = destination.split("digital-receipt/").last;
      RoutingService.push(ReceiptDetailScreen(orderId: orderId));
      return;
    }
    if (destination.contains("wallet")) {
      RoutingService.push(const WalletScreen());
      return;
    }
    if (destination.contains("transactions")) {
      RoutingService.push(const TransactionsScreen());
      return;
    }
    Prompts.showSnackBar("This page isn't available on mobile yet");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text("Notification", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: Obx(() {
        if (notificationsController.isLoadingDetail.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final notification = notificationsController.selected.value;
        if (notification == null) {
          return const Center(child: Text("Notification not found.", style: TextStyle(color: AppColors.textGrey)));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: notification.isRead ? AppColors.background : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        notification.isRead ? "Read" : "Unread",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: notification.isRead ? AppColors.textGrey : AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(20)),
                      child: Text(statusLabel(notification.kind), style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(notification.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(timeAgo(notification.createdAt), style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                const Divider(height: 32),
                Text(notification.description, style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textDark)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await notificationsController.deleteNotification(notification.id);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text("Delete"),
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton.icon(
                        icon: Icons.arrow_outward,
                        label: "Open related page",
                        onPressed: () => _openRelatedPage(notification.to),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
