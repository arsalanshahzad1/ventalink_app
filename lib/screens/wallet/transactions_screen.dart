import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/wallet_controller.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/widgets/ledger_entry_tile.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final walletController = Get.find<WalletController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text("Transactions", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: Obx(() {
        if (walletController.isLoadingLedger.value && walletController.ledgerEntries.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (walletController.ledgerEntries.isEmpty) {
          return const Center(
            child: Text("No ledger activity yet.", style: TextStyle(color: AppColors.textGrey)),
          );
        }

        return RefreshIndicator(
          onRefresh: walletController.loadLedger,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: walletController.ledgerEntries.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: LedgerEntryTile(entry: walletController.ledgerEntries[index]),
              );
            },
          ),
        );
      }),
    );
  }
}
