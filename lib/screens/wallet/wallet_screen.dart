import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/wallet_controller.dart';
import 'package:ventalink_mobile/screens/wallet/transactions_screen.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/utils/formatters.dart';
import 'package:ventalink_mobile/utils/prompts.dart';
import 'package:ventalink_mobile/utils/routing_service.dart';
import 'package:ventalink_mobile/widgets/custom_button.dart';
import 'package:ventalink_mobile/widgets/ledger_entry_tile.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final walletController = Get.find<WalletController>();
  final topUpAmountController = TextEditingController();
  final giftEmailController = TextEditingController();
  final giftAmountController = TextEditingController();
  final giftMessageController = TextEditingController();

  Widget _sectionCard({required String title, required Widget child, IconData? icon}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
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
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
              ],
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

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

  void _submitTopUp() {
    final entered = double.tryParse(topUpAmountController.text.trim());
    if (entered == null || entered <= 0) {
      Prompts.showSnackBar("Enter a valid amount");
      return;
    }
    walletController.submitTopUp((entered * 100).round());
    topUpAmountController.clear();
  }

  void _submitGift() {
    final email = giftEmailController.text.trim();
    final entered = double.tryParse(giftAmountController.text.trim());

    if (email.isEmpty || !email.contains("@")) {
      Prompts.showSnackBar("Enter the recipient email");
      return;
    }
    if (entered == null || entered <= 0) {
      Prompts.showSnackBar("Enter a valid gift amount");
      return;
    }

    walletController.sendGift(email, (entered * 100).round(), giftMessageController.text.trim());
    giftEmailController.clear();
    giftAmountController.clear();
    giftMessageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text("My Wallet", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: Obx(
        () => RefreshIndicator(
          onRefresh: () async {
            await walletController.loadWallet();
            await walletController.loadLedger();
            await walletController.loadTopUps();
          },
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
                    const Text("Available Balance", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Text(
                      walletController.wallet.value == null
                          ? "..."
                          : formatMoney(walletController.wallet.value!.balanceMinor, walletController.wallet.value!.currency),
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _sectionCard(
                title: "Add Funds",
                icon: Icons.add_card_outlined,
                child: Column(
                  children: [
                    TextField(
                      controller: topUpAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _fieldDecoration("Amount, e.g. 100.00"),
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      label: "Request Top-Up",
                      isLoading: walletController.isSubmittingTopUp.value,
                      onPressed: _submitTopUp,
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
              _sectionCard(
                title: "Gift Tokens",
                icon: Icons.card_giftcard_outlined,
                child: Column(
                  children: [
                    TextField(controller: giftEmailController, decoration: _fieldDecoration("Recipient email"), keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 10),
                    TextField(
                      controller: giftAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _fieldDecoration("Amount, e.g. 25.00"),
                    ),
                    const SizedBox(height: 10),
                    TextField(controller: giftMessageController, decoration: _fieldDecoration("Message (optional)")),
                    const SizedBox(height: 12),
                    CustomButton(
                      label: "Send Gift",
                      isLoading: walletController.isSendingGift.value,
                      onPressed: _submitGift,
                      height: 46,
                    ),
                  ],
                ),
              ),
              if (walletController.topUps.isNotEmpty)
                _sectionCard(
                  title: "Pending Top-Up Requests",
                  icon: Icons.pending_outlined,
                  child: Column(
                    children: walletController.topUps
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
                    if (walletController.isLoadingLedger.value)
                      const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator()))
                    else if (walletController.ledgerEntries.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: Text("No wallet activity yet.", style: TextStyle(color: AppColors.textGrey))),
                      )
                    else
                      ...walletController.ledgerEntries.take(5).map((entry) => LedgerEntryTile(entry: entry)),
                    TextButton(
                      onPressed: () => RoutingService.push(const TransactionsScreen()),
                      child: const Text("View All"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
