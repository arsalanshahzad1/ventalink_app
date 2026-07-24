import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/store/merchant_campaigns_controller.dart';
import 'package:ventalink_mobile/controllers/store/merchant_wallet_controller.dart';
import 'package:ventalink_mobile/screens/store/finance/campaigns_tab.dart';
import 'package:ventalink_mobile/screens/store/finance/push_tab.dart';
import 'package:ventalink_mobile/screens/store/finance/wallet_tab.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';

class StoreFinanceTabScreen extends StatefulWidget {
  const StoreFinanceTabScreen({super.key});

  @override
  State<StoreFinanceTabScreen> createState() => _StoreFinanceTabScreenState();
}

class _StoreFinanceTabScreenState extends State<StoreFinanceTabScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Get.find<MerchantWalletController>().loadAll();
    Get.find<MerchantCampaignsController>().loadCampaigns();
    Get.find<MerchantCampaignsController>().loadActivity();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text("Finance", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textGrey,
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [Tab(text: "Wallet"), Tab(text: "Campaigns"), Tab(text: "Push")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [WalletTab(), CampaignsTab(), PushTab()],
      ),
    );
  }
}
