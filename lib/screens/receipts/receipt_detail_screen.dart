import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/orders_controller.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/utils/formatters.dart';

class ReceiptDetailScreen extends StatefulWidget {
  final String orderId;

  const ReceiptDetailScreen({super.key, required this.orderId});

  @override
  State<ReceiptDetailScreen> createState() => _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends State<ReceiptDetailScreen> {
  final ordersController = Get.find<OrdersController>();

  @override
  void initState() {
    super.initState();
    ordersController.loadReceipt(widget.orderId);
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
          Text(
            value,
            style: TextStyle(fontSize: bold ? 16 : 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: AppColors.textDark),
          ),
        ],
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
        title: const Text("Receipt", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: Obx(() {
        if (ordersController.isLoadingReceipt.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ordersController.receiptLoadFailed.value || ordersController.receipt.value == null) {
          return const Center(child: Text("Could not load this receipt.", style: TextStyle(color: AppColors.textGrey)));
        }

        final receipt = ordersController.receipt.value!;
        final order = ordersController.receiptOrder.value;

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
                Text(receipt.storeName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                if (receipt.storeAddressLines.isNotEmpty)
                  Text(receipt.storeAddressLines.join(", "), style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                const SizedBox(height: 4),
                Text("Receipt ${receipt.receiptNumber}", style: const TextStyle(fontSize: 12, color: AppColors.textGrey, fontFamily: "monospace")),
                const Divider(height: 32),
                Text("Billed to", style: TextStyle(fontSize: 12, color: AppColors.textGrey.withValues(alpha: 0.9), fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(receipt.customerName, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(receipt.customerEmail, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                if (receipt.customerPhone.isNotEmpty)
                  Text(receipt.customerPhone, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                const Divider(height: 32),
                ...receipt.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text("${item.qty}x ${item.nameSnapshot}", style: const TextStyle(fontSize: 13)),
                        ),
                        Text(formatMoney(item.lineTotalMinor, receipt.currency), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 24),
                _row("Subtotal", formatMoney(receipt.subtotalMinor, receipt.currency)),
                _row("Total", formatMoney(receipt.totalMinor, receipt.currency), bold: true),
                const SizedBox(height: 12),
                _row("Payment method", statusLabel(receipt.paymentMethod)),
                _row("Payment status", statusLabel(receipt.paymentStatus)),
                if (order != null) _row("Order number", order.orderNumber),
                if (receipt.paidAt != null) _row("Paid at", formatDate(receipt.paidAt!)),
              ],
            ),
          ),
        );
      }),
    );
  }
}
