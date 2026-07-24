import 'package:ventalink_mobile/models/pagination_model.dart';

class OrderLineItem {
  String nameSnapshot;
  int qty;
  int unitPriceMinor;
  int lineTotalMinor;

  OrderLineItem({
    required this.nameSnapshot,
    required this.qty,
    required this.unitPriceMinor,
    required this.lineTotalMinor,
  });

  factory OrderLineItem.fromJson(Map<String, dynamic> json) => OrderLineItem(
    nameSnapshot: json["nameSnapshot"] ?? "",
    qty: json["qty"] ?? 1,
    unitPriceMinor: json["unitPriceMinor"] ?? 0,
    lineTotalMinor: json["lineTotalMinor"] ?? 0,
  );
}

class OrderSummary {
  String id;
  String orderNumber;
  int totalMinor;
  String currency;
  String status;
  String paymentStatus;
  String? paymentMethod;
  DateTime createdAt;
  String? customerName;
  String? customerEmail;
  String? customerPhone;
  List<OrderLineItem> items;
  String? storeName;

  OrderSummary({
    required this.id,
    required this.orderNumber,
    required this.totalMinor,
    required this.currency,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod,
    required this.createdAt,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    required this.items,
    this.storeName,
  });

  String get itemsSummary {
    if (items.isEmpty) return "No items";
    return items.map((item) => "${item.qty}x ${item.nameSnapshot}").join(", ");
  }

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    final customer = json["customer"] ?? {};
    final store = json["store"] ?? {};
    return OrderSummary(
      id: json["id"] ?? "",
      orderNumber: json["orderNumber"] ?? "",
      totalMinor: json["totalMinor"] ?? 0,
      currency: json["currency"] ?? "MXN",
      status: json["status"] ?? "pending",
      paymentStatus: json["paymentStatus"] ?? "unpaid",
      paymentMethod: json["paymentMethod"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
      customerName: customer["name"],
      customerEmail: customer["email"],
      customerPhone: customer["phone"],
      items: (json["items"] as List? ?? []).map((item) => OrderLineItem.fromJson(item)).toList(),
      storeName: store["name"],
    );
  }
}

class OrderSummaryResponse {
  List<OrderSummary> items;
  Pagination pagination;

  OrderSummaryResponse({required this.items, required this.pagination});

  factory OrderSummaryResponse.fromJson(Map<String, dynamic> json) => OrderSummaryResponse(
    items: (json["items"] as List? ?? []).map((item) => OrderSummary.fromJson(item)).toList(),
    pagination: Pagination.fromJson(json["pagination"] ?? {}),
  );
}

class OrderReceipt {
  String receiptNumber;
  String storeName;
  String storeWhatsapp;
  List<String> storeAddressLines;
  String customerName;
  String customerEmail;
  String customerPhone;
  List<OrderLineItem> items;
  int subtotalMinor;
  int totalMinor;
  String currency;
  String paymentMethod;
  String paymentStatus;
  DateTime? paidAt;

  OrderReceipt({
    required this.receiptNumber,
    required this.storeName,
    required this.storeWhatsapp,
    required this.storeAddressLines,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.items,
    required this.subtotalMinor,
    required this.totalMinor,
    required this.currency,
    required this.paymentMethod,
    required this.paymentStatus,
    this.paidAt,
  });

  factory OrderReceipt.fromJson(Map<String, dynamic> json) {
    final storeSnapshot = json["storeSnapshot"] ?? {};
    final customerSnapshot = json["customerSnapshot"] ?? {};
    return OrderReceipt(
      receiptNumber: json["receiptNumber"] ?? "",
      storeName: storeSnapshot["name"] ?? "",
      storeWhatsapp: storeSnapshot["whatsappNumber"] ?? "",
      storeAddressLines: (storeSnapshot["addressLines"] as List? ?? []).map((e) => e.toString()).toList(),
      customerName: customerSnapshot["name"] ?? "",
      customerEmail: customerSnapshot["email"] ?? "",
      customerPhone: customerSnapshot["phone"] ?? "",
      items: (json["items"] as List? ?? []).map((item) => OrderLineItem.fromJson(item)).toList(),
      subtotalMinor: json["subtotalMinor"] ?? 0,
      totalMinor: json["totalMinor"] ?? 0,
      currency: json["currency"] ?? "MXN",
      paymentMethod: json["paymentMethod"] ?? "",
      paymentStatus: json["paymentStatus"] ?? "",
      paidAt: json["paidAt"] == null ? null : DateTime.tryParse(json["paidAt"]),
    );
  }
}
