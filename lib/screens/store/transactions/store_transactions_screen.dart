import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/store/merchant_wallet_controller.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/widgets/ledger_entry_tile.dart';

class StoreTransactionsScreen extends StatelessWidget {
  const StoreTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final merchantWalletController = Get.find<MerchantWalletController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text("Transactions", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: Obx(() {
        if (merchantWalletController.isLoadingLedger.value && merchantWalletController.ledgerEntries.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (merchantWalletController.ledgerEntries.isEmpty) {
          return const Center(
            child: Text("No ledger activity yet.", style: TextStyle(color: AppColors.textGrey)),
          );
        }

        return RefreshIndicator(
          onRefresh: merchantWalletController.loadLedger,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: merchantWalletController.ledgerEntries.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: LedgerEntryTile(entry: merchantWalletController.ledgerEntries[index]),
              );
            },
          ),
        );
      }),
    );
  }
}
