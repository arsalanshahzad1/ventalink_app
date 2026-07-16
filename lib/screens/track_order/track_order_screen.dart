import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/track_order_controller.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/utils/formatters.dart';

class TrackOrderScreen extends StatefulWidget {
  final String? initialQuery;

  const TrackOrderScreen({super.key, this.initialQuery});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  final trackOrderController = Get.put(TrackOrderController());
  late final queryController = TextEditingController(text: widget.initialQuery ?? "");

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => trackOrderController.search(widget.initialQuery!));
    }
  }

  Widget _statusBadge(String status) {
    final normalized = status.toLowerCase();
    Color background;
    Color text;

    if (normalized == "paid") {
      background = const Color(0xFFDCFCE7);
      text = const Color(0xFF15803D);
    } else if (normalized == "failed" || normalized == "cancelled") {
      background = const Color(0xFFFEE2E2);
      text = const Color(0xFFB91C1C);
    } else {
      background = const Color(0xFFFEF3C7);
      text = const Color(0xFFB45309);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
      child: Text(statusLabel(status), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text("Track Order", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: TextField(
              controller: queryController,
              onSubmitted: trackOrderController.search,
              decoration: InputDecoration(
                hintText: "Order number, email, or phone",
                hintStyle: const TextStyle(color: AppColors.textGrey),
                prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward, color: AppColors.primary),
                  onPressed: () => trackOrderController.search(queryController.text),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (trackOrderController.isSearching.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!trackOrderController.hasSearched.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      "Enter your receipt number, order number, email, or phone from checkout to find your order.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                  ),
                );
              }

              if (trackOrderController.results.isEmpty) {
                return const Center(child: Text("No matching order found.", style: TextStyle(color: AppColors.textGrey)));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: trackOrderController.results.length,
                itemBuilder: (context, index) {
                  final order = trackOrderController.results[index];
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            _statusBadge(order.paymentStatus),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (order.storeName != null) Text(order.storeName!, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(formatMoney(order.totalMinor, order.currency), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                            Text(formatDate(order.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
