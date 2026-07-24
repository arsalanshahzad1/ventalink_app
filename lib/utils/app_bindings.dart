import 'dart:developer';

import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/auth_controller.dart';
import 'package:ventalink_mobile/controllers/marketplace_controller.dart';
import 'package:ventalink_mobile/controllers/notifications_controller.dart';
import 'package:ventalink_mobile/controllers/orders_controller.dart';
import 'package:ventalink_mobile/controllers/store/loyalty_controller.dart';
import 'package:ventalink_mobile/controllers/store/merchant_campaigns_controller.dart';
import 'package:ventalink_mobile/controllers/store/merchant_wallet_controller.dart';
import 'package:ventalink_mobile/controllers/store/push_campaigns_controller.dart';
import 'package:ventalink_mobile/controllers/store/store_dashboard_controller.dart';
import 'package:ventalink_mobile/controllers/store/store_orders_controller.dart';
import 'package:ventalink_mobile/controllers/store/store_products_controller.dart';
import 'package:ventalink_mobile/controllers/store/store_profile_controller.dart';
import 'package:ventalink_mobile/controllers/store/store_shell_controller.dart';
import 'package:ventalink_mobile/controllers/wallet_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    log("AppBindings OverrideMethodCalled()");
    Get.put(AuthController(), permanent: true);
    Get.put(WalletController(), permanent: true);
    Get.put(OrdersController(), permanent: true);
    Get.put(NotificationsController(), permanent: true);
    Get.put(MarketplaceController(), permanent: true);

    // Store role
    Get.put(StoreShellController(), permanent: true);
    Get.put(StoreProfileController(), permanent: true);
    Get.put(StoreDashboardController(), permanent: true);
    Get.put(StoreProductsController(), permanent: true);
    Get.put(StoreOrdersController(), permanent: true);
    Get.put(MerchantWalletController(), permanent: true);
    Get.put(MerchantCampaignsController(), permanent: true);
    Get.put(PushCampaignsController(), permanent: true);
    Get.put(LoyaltyController(), permanent: true);
  }
}
