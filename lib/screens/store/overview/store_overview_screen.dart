import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/store/store_dashboard_controller.dart';
import 'package:ventalink_mobile/controllers/store/store_orders_controller.dart';
import 'package:ventalink_mobile/controllers/store/store_profile_controller.dart';
import 'package:ventalink_mobile/controllers/store/store_shell_controller.dart';
import 'package:ventalink_mobile/screens/store/settings/store_settings_screen.dart';
import 'package:ventalink_mobile/screens/store/share/store_share_screen.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/utils/formatters.dart';
import 'package:ventalink_mobile/utils/routing_service.dart';
import 'package:ventalink_mobile/widgets/brand_mark.dart';

class StoreOverviewScreen extends StatelessWidget {
  const StoreOverviewScreen({super.key});

  Widget _metricTile(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textDark)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(IconData icon, String title, String copy, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textDark)),
              const SizedBox(height: 4),
              Text(copy, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeProfileController = Get.find<StoreProfileController>();
    final storeDashboardController = Get.find<StoreDashboardController>();
    final storeOrdersController = Get.find<StoreOrdersController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          final store = storeProfileController.store.value;
          final metrics = storeDashboardController.metrics.value;

          return RefreshIndicator(
            onRefresh: () async {
              await storeDashboardController.loadMetrics();
              await storeOrdersController.loadOrders(status: "all");
            },
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  children: [
                    const BrandMark(size: 32),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        store?.name ?? "Your Store",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => RoutingService.push(const StoreShareScreen()),
                      icon: const Icon(Icons.qr_code_outlined, color: AppColors.textDark),
                    ),
                    IconButton(
                      onPressed: () => RoutingService.push(const StoreSettingsScreen()),
                      icon: const Icon(Icons.settings_outlined, color: AppColors.textGrey, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (metrics == null)
                  const Padding(padding: EdgeInsets.symmetric(vertical: 30), child: Center(child: CircularProgressIndicator()))
                else ...[
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _metricTile("Total Sales", formatMoney(metrics.totalSalesMinor, metrics.currency), Icons.trending_up),
                        const SizedBox(width: 10),
                        _metricTile("Orders Today", "${metrics.ordersToday}", Icons.today_outlined),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _metricTile("Active Products", "${metrics.activeProducts}", Icons.inventory_2_outlined),
                        const SizedBox(width: 10),
                        _metricTile("Pending Orders", "${metrics.pendingOrders}", Icons.pending_actions_outlined),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _actionCard(
                          Icons.account_balance_wallet_outlined,
                          "Merchant Balance",
                          formatMoney(metrics.merchantBalanceMinor, metrics.currency),
                          () => Get.find<StoreShellController>().goToTab(3),
                        ),
                        const SizedBox(width: 12),
                        _actionCard(
                          Icons.campaign_outlined,
                          "Active Campaigns",
                          "${metrics.activeCampaigns} running",
                          () => Get.find<StoreShellController>().goToTab(3),
                        ),
                        const SizedBox(width: 12),
                        _actionCard(
                          Icons.tune_outlined,
                          "Checkout",
                          metrics.checkoutSettings.acceptsWalletPayments ? "Wallet on" : "Wallet off",
                          () => RoutingService.push(const StoreSettingsScreen()),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Recent Orders", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textDark)),
                  ],
                ),
                const SizedBox(height: 12),
                if (storeOrdersController.isLoading.value)
                  const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator()))
                else if (storeOrdersController.orders.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text("No orders yet.", style: TextStyle(color: AppColors.textGrey))),
                  )
                else
                  ...storeOrdersController.orders.take(4).map(
                    (order) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                Text(order.customerName ?? "Guest", style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                              ],
                            ),
                          ),
                          Text(formatMoney(order.totalMinor, order.currency), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
