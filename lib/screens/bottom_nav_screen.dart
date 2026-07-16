import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/notifications_controller.dart';
import 'package:ventalink_mobile/controllers/orders_controller.dart';
import 'package:ventalink_mobile/controllers/wallet_controller.dart';
import 'package:ventalink_mobile/screens/home_screen.dart';
import 'package:ventalink_mobile/screens/receipts/digital_receipts_screen.dart';
import 'package:ventalink_mobile/screens/wallet/transactions_screen.dart';
import 'package:ventalink_mobile/screens/wallet/wallet_screen.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int currentTab = 0;

  final tabs = const [
    HomeScreen(),
    WalletScreen(),
    DigitalReceiptsScreen(),
    TransactionsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Get.find<WalletController>().loadAll();
    Get.find<OrdersController>().loadPurchaseHistory();
    Get.find<NotificationsController>().loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentTab, children: tabs),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: const Border(top: BorderSide(color: AppColors.border, width: 1)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
        ),
        child: BottomNavigationBar(
          currentIndex: currentTab,
          onTap: (index) => setState(() => currentTab = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textGrey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: "Wallet"),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: "Receipts"),
            BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: "Transactions"),
          ],
        ),
      ),
    );
  }
}
