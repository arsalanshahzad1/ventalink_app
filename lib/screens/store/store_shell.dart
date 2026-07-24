import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/store/store_dashboard_controller.dart';
import 'package:ventalink_mobile/controllers/store/store_orders_controller.dart';
import 'package:ventalink_mobile/controllers/store/store_products_controller.dart';
import 'package:ventalink_mobile/controllers/store/store_profile_controller.dart';
import 'package:ventalink_mobile/controllers/store/store_shell_controller.dart';
import 'package:ventalink_mobile/screens/store/more/store_more_screen.dart';
import 'package:ventalink_mobile/screens/store/orders/store_orders_screen.dart';
import 'package:ventalink_mobile/screens/store/overview/store_overview_screen.dart';
import 'package:ventalink_mobile/screens/store/products/store_products_screen.dart';
import 'package:ventalink_mobile/screens/store/finance/store_finance_tab_screen.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';

class StoreShellScreen extends StatefulWidget {
  const StoreShellScreen({super.key});

  @override
  State<StoreShellScreen> createState() => _StoreShellScreenState();
}

class _StoreShellScreenState extends State<StoreShellScreen> {
  final storeShellController = Get.find<StoreShellController>();

  final tabs = const [
    StoreOverviewScreen(),
    StoreProductsScreen(),
    StoreOrdersScreen(),
    StoreFinanceTabScreen(),
    StoreMoreScreen(),
  ];

  @override
  void initState() {
    super.initState();
    storeShellController.currentTab.value = 0;
    Get.find<StoreProfileController>().loadMyStore();
    Get.find<StoreDashboardController>().loadMetrics();
    Get.find<StoreProductsController>().loadProducts();
    Get.find<StoreOrdersController>().loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentTab = storeShellController.currentTab.value;
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
            onTap: storeShellController.goToTab,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textGrey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: "Overview"),
              BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: "Products"),
              BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: "Orders"),
              BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: "Finance"),
              BottomNavigationBarItem(icon: Icon(Icons.more_horiz), activeIcon: Icon(Icons.more_horiz), label: "More"),
            ],
          ),
        ),
      );
    });
  }
}
