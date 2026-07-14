import 'dart:developer';

import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/auth_controller.dart';
import 'package:ventalink_mobile/controllers/marketplace_controller.dart';
import 'package:ventalink_mobile/controllers/notifications_controller.dart';
import 'package:ventalink_mobile/controllers/orders_controller.dart';
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
  }
}
