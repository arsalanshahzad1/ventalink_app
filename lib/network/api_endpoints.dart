class ApiEndpoints {
  static String signUp = "auth/signup";
  static String login = "auth/login";
  static String me = "auth/me";
  static String logout = "auth/logout";

  static String myWallet = "wallets/me";
  static String myWalletLedger = "wallets/me/ledger";
  static String myWalletTopUps = "wallets/me/top-ups";
  static String walletGift = "wallets/me/gifts";

  static String myPurchaseHistory = "orders/my-history";
  static String orderReceipt(String orderId) => "orders/$orderId/receipt";

  static String notifications = "notifications";
  static String notificationDetail(String id) => "notifications/$id";
  static String markNotificationRead(String id) => "notifications/$id/read";
  static String markAllNotificationsRead = "notifications/read-all";
  static String clearNotifications = "notifications/clear-all";

  static String marketplace = "public/marketplace";
  static String storeBySlug(String slug) => "public/stores/$slug";
  static String toggleProductFavourite(String productId) => "products/$productId/favourite";

  static String orderLookup = "public/orders/lookup";
}

class GlobalEndpoints {
  static const String appOrigin = "https://api.ventalink.mx";
  static const String appBackend = "$appOrigin/api/v1/";
}
