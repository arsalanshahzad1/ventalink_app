import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/store/merchant_wallet_controller.dart';
import 'package:ventalink_mobile/screens/store/transactions/store_transactions_screen.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/utils/formatters.dart';
import 'package:ventalink_mobile/utils/prompts.dart';
import 'package:ventalink_mobile/utils/routing_service.dart';
import 'package:ventalink_mobile/widgets/custom_button.dart';
import 'package:ventalink_mobile/widgets/ledger_entry_tile.dart';

class WalletTab extends StatefulWidget {
  const WalletTab({super.key});

  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  final merchantWalletController = Get.find<MerchantWalletController>();
  final amountController = TextEditingController();

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textGrey),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  Widget _sectionCard({required String title, required Widget child, IconData? icon}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[Icon(icon, size: 18, color: AppColors.primary), const SizedBox(width: 8)],
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  void _submitBulkPurchase() {
    final entered = double.tryParse(amountController.text.trim());
    if (entered == null || entered <= 0) {
      Prompts.showSnackBar("Enter a valid amount");
      return;
    }
    merchantWalletController.submitBulkPurchase((entered * 100).round());
    amountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => RefreshIndicator(
        onRefresh: merchantWalletController.loadAll,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Merchant Balance", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Text(
                    merchantWalletController.wallet.value == null
                        ? "..."
                        : formatMoney(merchantWalletController.wallet.value!.balanceMinor, merchantWalletController.wallet.value!.currency),
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _sectionCard(
              title: "Bulk Purchase",
              icon: Icons.add_card_outlined,
              child: Column(
                children: [
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: _fieldDecoration("Amount, e.g. 500.00"),
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    label: "Request Bulk Purchase",
                    isLoading: merchantWalletController.isSubmittingBulkPurchase.value,
                    onPressed: _submitBulkPurchase,
                    height: 46,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Requests require admin confirmation before funds are available.",
                    style: TextStyle(fontSize: 11, color: AppColors.textGrey),
                  ),
                ],
              ),
            ),
            if (merchantWalletController.bulkPurchases.isNotEmpty)
              _sectionCard(
                title: "Pending Requests",
                icon: Icons.pending_outlined,
                child: Column(
                  children: merchantWalletController.bulkPurchases
                      .map(
                        (intent) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(intent.referenceId, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                    Text(formatDate(intent.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(formatMoney(intent.amountMinor, intent.currency), style: const TextStyle(fontWeight: FontWeight.w700)),
                                  Text(statusLabel(intent.status), style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            _sectionCard(
              title: "Recent Activity",
              icon: Icons.history,
              child: Column(
                children: [
                  if (merchantWalletController.isLoadingLedger.value)
                    const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator()))
                  else if (merchantWalletController.ledgerEntries.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text("No wallet activity yet.", style: TextStyle(color: AppColors.textGrey))),
                    )
                  else
                    ...merchantWalletController.ledgerEntries.take(5).map((entry) => LedgerEntryTile(entry: entry)),
                  TextButton(
                    onPressed: () => RoutingService.push(const StoreTransactionsScreen()),
                    child: const Text("View All"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
