class PaymentMetrics {
  int totalTokenMinor;
  int totalMxnPaidViaSpeiMinor;
  int totalMxnPaidViaCardMinor;
  int walletOrdersCount;
  int speiOrdersCount;
  int cardOrdersCount;
  int hybridOrdersCount;
  int hybridSalesMinor;
  int hybridTokenMinor;
  int hybridExternalMinor;

  PaymentMetrics({
    required this.totalTokenMinor,
    required this.totalMxnPaidViaSpeiMinor,
    required this.totalMxnPaidViaCardMinor,
    required this.walletOrdersCount,
    required this.speiOrdersCount,
    required this.cardOrdersCount,
    required this.hybridOrdersCount,
    required this.hybridSalesMinor,
    required this.hybridTokenMinor,
    required this.hybridExternalMinor,
  });

  factory PaymentMetrics.fromJson(Map<String, dynamic>? json) {
    final data = json ?? {};
    return PaymentMetrics(
      totalTokenMinor: data["totalTokenMinor"] ?? 0,
      totalMxnPaidViaSpeiMinor: data["totalMxnPaidViaSpeiMinor"] ?? 0,
      totalMxnPaidViaCardMinor: data["totalMxnPaidViaCardMinor"] ?? 0,
      walletOrdersCount: data["walletOrdersCount"] ?? 0,
      speiOrdersCount: data["speiOrdersCount"] ?? 0,
      cardOrdersCount: data["cardOrdersCount"] ?? 0,
      hybridOrdersCount: data["hybridOrdersCount"] ?? 0,
      hybridSalesMinor: data["hybridSalesMinor"] ?? 0,
      hybridTokenMinor: data["hybridTokenMinor"] ?? 0,
      hybridExternalMinor: data["hybridExternalMinor"] ?? 0,
    );
  }
}

class CheckoutSettings {
  bool acceptsWalletPayments;
  bool acceptsHybridPayments;

  CheckoutSettings({required this.acceptsWalletPayments, required this.acceptsHybridPayments});

  factory CheckoutSettings.fromJson(Map<String, dynamic>? json) {
    final data = json ?? {};
    return CheckoutSettings(
      acceptsWalletPayments: data["acceptsWalletPayments"] ?? false,
      acceptsHybridPayments: data["acceptsHybridPayments"] ?? false,
    );
  }
}

class DashboardMetrics {
  int totalSalesMinor;
  int ordersToday;
  int activeProducts;
  int pendingOrders;
  String currency;
  int merchantBalanceMinor;
  int merchantLockedBalanceMinor;
  int activeCampaigns;
  int totalTokenMinor;
  int totalMxnPaidViaSpeiMinor;
  int totalMxnPaidViaCardMinor;
  int hybridSalesMinor;
  int hybridTokenMinor;
  int hybridExternalMinor;
  CheckoutSettings checkoutSettings;
  PaymentMetrics paymentMetrics;

  DashboardMetrics({
    required this.totalSalesMinor,
    required this.ordersToday,
    required this.activeProducts,
    required this.pendingOrders,
    required this.currency,
    required this.merchantBalanceMinor,
    required this.merchantLockedBalanceMinor,
    required this.activeCampaigns,
    required this.totalTokenMinor,
    required this.totalMxnPaidViaSpeiMinor,
    required this.totalMxnPaidViaCardMinor,
    required this.hybridSalesMinor,
    required this.hybridTokenMinor,
    required this.hybridExternalMinor,
    required this.checkoutSettings,
    required this.paymentMetrics,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) => DashboardMetrics(
    totalSalesMinor: json["totalSalesMinor"] ?? 0,
    ordersToday: json["ordersToday"] ?? 0,
    activeProducts: json["activeProducts"] ?? 0,
    pendingOrders: json["pendingOrders"] ?? 0,
    currency: json["currency"] ?? "MXN",
    merchantBalanceMinor: json["merchantBalanceMinor"] ?? 0,
    merchantLockedBalanceMinor: json["merchantLockedBalanceMinor"] ?? 0,
    activeCampaigns: json["activeCampaigns"] ?? 0,
    totalTokenMinor: json["totalTokenMinor"] ?? 0,
    totalMxnPaidViaSpeiMinor: json["totalMxnPaidViaSpeiMinor"] ?? 0,
    totalMxnPaidViaCardMinor: json["totalMxnPaidViaCardMinor"] ?? 0,
    hybridSalesMinor: json["hybridSalesMinor"] ?? 0,
    hybridTokenMinor: json["hybridTokenMinor"] ?? 0,
    hybridExternalMinor: json["hybridExternalMinor"] ?? 0,
    checkoutSettings: CheckoutSettings.fromJson(json["checkoutSettings"]),
    paymentMetrics: PaymentMetrics.fromJson(json["paymentMetrics"]),
  );
}
