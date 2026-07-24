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
  static String publicOrders = "public/orders";

  // Store profile
  static String myStore = "stores/me";
  static String createStore = "stores";
  static String slugAvailability = "stores/slug-availability";

  // Merchant products
  static String products = "products";
  static String productDetail(String id) => "products/$id";

  // Seller-side orders (distinct from myPurchaseHistory, which is the buyer view)
  static String sellerOrders = "orders";
  static String sellerOrderDetail(String id) => "orders/$id";

  // Dashboard
  static String dashboardMetrics = "dashboard/metrics";

  // Merchant wallet / campaigns / push notifications
  static String merchantWallet = "merchant/wallet";
  static String merchantWalletLedger = "merchant/wallet/ledger";
  static String merchantBulkPurchases = "merchant/wallet/bulk-purchases";
  static String merchantCampaigns = "merchant/campaigns";
  static String merchantCampaignDetail(String id) => "merchant/campaigns/$id";
  static String merchantCampaignActivity = "merchant/campaigns/activity";
  static String pushCampaigns = "merchant/push-campaigns";
  static String pushCampaignEstimate = "merchant/push-campaigns/estimate";

  // Loyalty
  static String loyaltyProgram = "loyalty/program";
  static String loyaltyCoupons = "loyalty/coupons";
  static String redeemLoyaltyCoupon(String code) => "loyalty/coupons/$code/redeem";
}

class GlobalEndpoints {
  static const String appOrigin = "https://api.ventalink.mx";
  static const String appBackend = "$appOrigin/api/v1/";
  static const String publicAppUrl = "https://ventalink.app";
}
