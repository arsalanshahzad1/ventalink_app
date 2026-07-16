class OrderPaymentBankInfo {
  String? bank;
  String? clabe;

  OrderPaymentBankInfo({this.bank, this.clabe});

  factory OrderPaymentBankInfo.fromJson(Map<String, dynamic> json) => OrderPaymentBankInfo(
    bank: json["bank"],
    clabe: json["clabe"],
  );
}

class OrderPaymentInfo {
  String? reference;
  String? voucherUrl;
  OrderPaymentBankInfo? bank;

  OrderPaymentInfo({this.reference, this.voucherUrl, this.bank});

  factory OrderPaymentInfo.fromJson(Map<String, dynamic> json) {
    final data = json["data"] ?? {};
    return OrderPaymentInfo(
      reference: json["reference"],
      voucherUrl: json["voucherUrl"],
      bank: data["bank"] == null ? null : OrderPaymentBankInfo.fromJson(data["bank"]),
    );
  }
}

class CreatedOrder {
  String id;
  String orderNumber;
  String status;
  String? paymentStatus;
  String? paymentMethod;
  int totalMinor;
  String currency;

  CreatedOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    this.paymentStatus,
    this.paymentMethod,
    required this.totalMinor,
    required this.currency,
  });

  bool get isPaid => (paymentStatus ?? status).toLowerCase() == "paid";

  factory CreatedOrder.fromJson(Map<String, dynamic> json) => CreatedOrder(
    id: json["id"] ?? "",
    orderNumber: json["orderNumber"] ?? "",
    status: json["status"] ?? "pending",
    paymentStatus: json["paymentStatus"],
    paymentMethod: json["paymentMethod"],
    totalMinor: json["totalMinor"] ?? 0,
    currency: json["currency"] ?? "MXN",
  );
}

class CreatePublicOrderResult {
  bool success;
  CreatedOrder? order;
  OrderPaymentInfo? payment;

  CreatePublicOrderResult({required this.success, this.order, this.payment});

  factory CreatePublicOrderResult.fromJson(Map<String, dynamic> json) {
    final result = json["result"] ?? {};
    return CreatePublicOrderResult(
      success: json["success"] ?? true,
      order: result["order"] == null ? null : CreatedOrder.fromJson(result["order"]),
      payment: json["payment"] == null ? null : OrderPaymentInfo.fromJson(json["payment"]),
    );
  }
}
