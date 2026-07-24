import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ventalink_mobile/controllers/store/store_orders_controller.dart';
import 'package:ventalink_mobile/models/order_model.dart';
import 'package:ventalink_mobile/screens/store/orders/store_receipt_screen.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/utils/formatters.dart';
import 'package:ventalink_mobile/utils/routing_service.dart';

class StoreOrdersScreen extends StatefulWidget {
  const StoreOrdersScreen({super.key});

  @override
  State<StoreOrdersScreen> createState() => _StoreOrdersScreenState();
}

class _StoreOrdersScreenState extends State<StoreOrdersScreen> {
  final storeOrdersController = Get.find<StoreOrdersController>();

  Widget _filterChip(String value, String label) {
    return Obx(() {
      final selected = storeOrdersController.statusFilter.value == value;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => storeOrdersController.loadOrders(status: value),
          selectedColor: AppColors.primary.withValues(alpha: 0.15),
          labelStyle: TextStyle(color: selected ? AppColors.primary : AppColors.textGrey, fontWeight: FontWeight.w600, fontSize: 12),
          side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
          backgroundColor: AppColors.white,
        ),
      );
    });
  }

  void _messageOnWhatsApp(String? phone) {
    final digits = (phone ?? "").replaceAll(RegExp(r"[^0-9]"), "");
    if (digits.isEmpty) return;
    launchUrl(Uri.parse("https://wa.me/$digits"), mode: LaunchMode.externalApplication);
  }

  Widget _orderTile(OrderSummary order) {
    final isPaid = order.paymentStatus == "paid";

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          subtitle: Text(order.customerName ?? "Guest", style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatMoney(order.totalMinor, order.currency), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              Text(statusLabel(order.paymentStatus), style: TextStyle(fontSize: 10, color: isPaid ? const Color(0xFF16A34A) : AppColors.textGrey)),
            ],
          ),
          children: [
            const Divider(),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(child: Text("${item.qty}x ${item.nameSnapshot}", style: const TextStyle(fontSize: 13))),
                    Text(formatMoney(item.lineTotalMinor, order.currency), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(timeAgo(order.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
            const SizedBox(height: 12),
            Row(
              children: [
                if ((order.customerPhone ?? "").isNotEmpty)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _messageOnWhatsApp(order.customerPhone),
                      icon: const Icon(Icons.chat_outlined, size: 16),
                      label: const Text("WhatsApp", style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.border)),
                    ),
                  ),
                if ((order.customerPhone ?? "").isNotEmpty) const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isPaid ? () => RoutingService.push(StoreReceiptScreen(orderId: order.id)) : null,
                    icon: const Icon(Icons.receipt_long_outlined, size: 16),
                    label: const Text("Receipt", style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.border)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text("Orders", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
      ),
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: () => storeOrdersController.loadOrders(status: storeOrdersController.statusFilter.value),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(children: [_filterChip("all", "All"), _filterChip("pending", "Pending"), _filterChip("paid", "Paid")]),
              const SizedBox(height: 16),
              if (storeOrdersController.isLoading.value)
                const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: CircularProgressIndicator()))
              else if (storeOrdersController.orders.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text("No orders yet.", style: TextStyle(color: AppColors.textGrey))),
                )
              else
                ...storeOrdersController.orders.map(_orderTile),
            ],
          ),
        );
      }),
    );
  }
}
