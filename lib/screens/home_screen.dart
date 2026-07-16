import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/notifications_controller.dart';
import 'package:ventalink_mobile/controllers/wallet_controller.dart';
import 'package:ventalink_mobile/screens/marketplace/marketplace_screen.dart';
import 'package:ventalink_mobile/screens/notifications/notifications_screen.dart';
import 'package:ventalink_mobile/screens/profile/profile_screen.dart';
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
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: AppColors.primary, size: 20), 
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark),
              ),
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
                        onPressed: () => RoutingService.push(const ProfileScreen()),
                        icon: const Icon(Icons.person_outline, color: AppColors.textGrey, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 220),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: AppColors.primaryGradient,
                      boxShadow: [BoxShadow(color: const Color(0xFFF97316).withValues(alpha: 0.30), blurRadius: 24, offset: const Offset(0, 12))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          // Decorative background circles
                          Positioned(
                            top: -70,
                            right: -45,
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08)),
                            ),
                          ),

                          Positioned(
                            bottom: -85,
                            left: -35,
                            child: Container(
                              width: 190,
                              height: 190,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withValues(alpha: 0.06)),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Card title and brand
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "YOUR WALLET",
                                      style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.3),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(20)),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 15),
                                          SizedBox(width: 5),
                                          Text(
                                            "WALLET",
                                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 18),

                                // Chip-style icon
                                Container(
                                  width: 46,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [Color(0xFFFFD88A), Color(0xFFC99B42)]),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                                  ),
                                  child: const Icon(Icons.grid_view_rounded, color: Color(0xFF8D682A), size: 22),
                                ),

                                const SizedBox(height: 18),

                                Obx(() {
                                  final wallet = walletController.wallet.value;

                                  return Text(
                                    wallet == null ? "..." : formatMoney(wallet.balanceMinor, wallet.currency),
                                    style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                                  );
                                }),

                                const SizedBox(height: 4),

                                const Text(
                                  "Available for wallet checkout",
                                  style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                                ),

                                const SizedBox(height: 22),

                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => RoutingService.push(const MarketplaceScreen()),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          side: BorderSide(color: Colors.white.withValues(alpha: 0.55)),
                                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        child: const Text("Browse Stores", style: TextStyle(fontWeight: FontWeight.w700)),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => RoutingService.push(const WalletScreen()),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: const Color(0xFFF97316),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        child: const Text("Top Up", style: TextStyle(fontWeight: FontWeight.w800)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _actionCard(Icons.add_card_outlined, "Top Up", "Add funds to your wallet", () => RoutingService.push(const WalletScreen())),
                        const SizedBox(width: 12),
                        _actionCard(Icons.storefront_outlined, "Shop", "Browse stores near you", () => RoutingService.push(const MarketplaceScreen())),
                        const SizedBox(width: 12),
                        _actionCard(Icons.card_giftcard_outlined, "Rewards", "Cashback in your ledger", () => RoutingService.push(const WalletScreen())),
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
