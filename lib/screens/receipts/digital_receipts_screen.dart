import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/orders_controller.dart';
import 'package:ventalink_mobile/models/order_model.dart';
import 'package:ventalink_mobile/screens/receipts/receipt_detail_screen.dart';
import 'package:ventalink_mobile/screens/track_order/track_order_screen.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/utils/formatters.dart';
import 'package:ventalink_mobile/utils/routing_service.dart';
import 'package:ventalink_mobile/widgets/gradient_button.dart';

class DigitalReceiptsScreen extends StatelessWidget {
  const DigitalReceiptsScreen({super.key});

  String _resolveStatus(OrderSummary order) {
    if (order.paymentStatus == "paid" || order.status == "paid") return "paid";
    return "pending";
  }

  @override
  Widget build(BuildContext context) {
    final ordersController = Get.find<OrdersController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text("Digital Receipt", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
        actions: [
          TextButton.icon(
            onPressed: () => RoutingService.push(const TrackOrderScreen()),
            icon: const Icon(Icons.search, size: 18, color: AppColors.primary),
            label: const Text("Track order", style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: Obx(() {
        if (ordersController.isLoadingHistory.value && ordersController.purchaseHistory.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ordersController.purchaseHistory.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 48, color: AppColors.textGrey),
                  SizedBox(height: 12),
                  Text("No paid or pending orders found.", style: TextStyle(color: AppColors.textGrey)),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: ordersController.loadPurchaseHistory,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: ordersController.purchaseHistory.length,
            itemBuilder: (context, index) {
              final order = ordersController.purchaseHistory[index];
              final isPaid = _resolveStatus(order) == "paid";

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(order.orderNumber, style: const TextStyle(fontSize: 11, color: AppColors.textGrey, fontFamily: "monospace")),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isPaid ? "Paid" : "Pending",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isPaid ? const Color(0xFF15803D) : const Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(order.itemsSummary, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(formatDate(order.createdAt), style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formatMoney(order.totalMinor, order.currency), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        isPaid
                            ? GradientButton.icon(
                                icon: Icons.receipt_long,
                                label: "Open receipt",
                                onPressed: () => RoutingService.push(ReceiptDetailScreen(orderId: order.id)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                borderRadius: 10,
                              )
                            : OutlinedButton(
                                onPressed: null,
                                child: const Text("Pending payment"),
                              ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
