import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/auth_controller.dart';
import 'package:ventalink_mobile/controllers/notifications_controller.dart';
import 'package:ventalink_mobile/controllers/wallet_controller.dart';
import 'package:ventalink_mobile/screens/marketplace/marketplace_screen.dart';
import 'package:ventalink_mobile/screens/notifications/notifications_screen.dart';
import 'package:ventalink_mobile/screens/wallet/wallet_screen.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/utils/common_utils.dart';
import 'package:ventalink_mobile/utils/formatters.dart';
import 'package:ventalink_mobile/utils/routing_service.dart';
import 'package:ventalink_mobile/widgets/brand_mark.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _actionCard(IconData icon, String title, String copy, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark)),
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
    final authController = Get.find<AuthController>();
    final walletController = Get.find<WalletController>();
    final notificationsController = Get.find<NotificationsController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder(
          future: CommonUtils().getSession(),
          builder: (context, snapshot) {
            final user = snapshot.data?.user;
            return RefreshIndicator(
              onRefresh: () async {
                await walletController.loadWallet();
                await notificationsController.loadNotifications();
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
                          "Hi, ${(user?.fullName ?? "there").split(" ").first}",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark),
                        ),
                      ),
                      Obx(
                        () => Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              onPressed: () => RoutingService.push(const NotificationsScreen()),
                              icon: const Icon(Icons.notifications_outlined, color: AppColors.textDark),
                            ),
                            if (notificationsController.unreadCount.value > 0)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                  child: Text(
                                    "${notificationsController.unreadCount.value}",
                                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: authController.logOut,
                        icon: const Icon(Icons.logout, color: AppColors.textGrey, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Your wallet", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Obx(() {
                          final wallet = walletController.wallet.value;
                          return Text(
                            wallet == null ? "..." : formatMoney(wallet.balanceMinor, wallet.currency),
                            style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800),
                          );
                        }),
                        const SizedBox(height: 4),
                        const Text("Available for wallet checkout", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => RoutingService.push(const MarketplaceScreen()),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white54),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text("Browse Stores"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => RoutingService.push(const WalletScreen()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text("Top Up", style: TextStyle(fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _actionCard(
                          Icons.add_card_outlined,
                          "Top Up",
                          "Add funds to your wallet",
                          () => RoutingService.push(const WalletScreen()),
                        ),
                        const SizedBox(width: 12),
                        _actionCard(
                          Icons.storefront_outlined,
                          "Shop",
                          "Browse stores near you",
                          () => RoutingService.push(const MarketplaceScreen()),
                        ),
                        const SizedBox(width: 12),
                        _actionCard(
                          Icons.card_giftcard_outlined,
                          "Rewards",
                          "Cashback in your ledger",
                          () => RoutingService.push(const WalletScreen()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
