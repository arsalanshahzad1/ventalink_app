import 'package:ventalink_mobile/models/pagination_model.dart';

class Wallet {
  String id;
  int balanceMinor;
  int lockedBalanceMinor;
  String currency;
  String status;

  Wallet({
    required this.id,
    required this.balanceMinor,
    required this.lockedBalanceMinor,
    required this.currency,
    required this.status,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
    id: json["id"] ?? "",
    balanceMinor: json["balanceMinor"] ?? 0,
    lockedBalanceMinor: json["lockedBalanceMinor"] ?? 0,
    currency: json["currency"] ?? "MXN",
    status: json["status"] ?? "active",
  );
}

class RelatedOrderItem {
  String nameSnapshot;
  int qty;

  RelatedOrderItem({required this.nameSnapshot, required this.qty});

  factory RelatedOrderItem.fromJson(Map<String, dynamic> json) =>
      RelatedOrderItem(nameSnapshot: json["nameSnapshot"] ?? "", qty: json["qty"] ?? 1);
}

class RelatedOrder {
  String id;
  String orderNumber;
  List<RelatedOrderItem> items;

  RelatedOrder({required this.id, required this.orderNumber, required this.items});

  factory RelatedOrder.fromJson(Map<String, dynamic> json) => RelatedOrder(
    id: json["id"] ?? "",
    orderNumber: json["orderNumber"] ?? "",
    items: (json["items"] as List? ?? []).map((item) => RelatedOrderItem.fromJson(item)).toList(),
  );
}

class WalletLedgerEntry {
  String id;
  String direction;
  String transactionType;
  int amountMinor;
  int balanceBeforeMinor;
  int balanceAfterMinor;
  String currency;
  String? paymentMethod;
  String? referenceId;
  String? storeName;
  String status;
  RelatedOrder? relatedOrder;
  Map<String, dynamic>? metadata;
  DateTime createdAt;

  WalletLedgerEntry({
    required this.id,
    required this.direction,
    required this.transactionType,
    required this.amountMinor,
    required this.balanceBeforeMinor,
    required this.balanceAfterMinor,
    required this.currency,
    this.paymentMethod,
    this.referenceId,
    this.storeName,
    required this.status,
    this.relatedOrder,
    this.metadata,
    required this.createdAt,
  });

  bool get isCredit => direction == "credit";

  bool get isGift =>
      transactionType == "gift" ||
      (transactionType == "transfer" &&
          (metadata?["source"] == "user_gift" || (referenceId ?? "").startsWith("gift-")));

  String? get senderName => metadata?["senderName"];
  String? get senderEmail => metadata?["senderEmail"];
  String? get recipientName => metadata?["recipientName"];
  String? get recipientEmail => metadata?["recipientEmail"];
  String? get giftMessage => metadata?["message"];

  factory WalletLedgerEntry.fromJson(Map<String, dynamic> json) => WalletLedgerEntry(
    id: json["id"] ?? "",
    direction: json["direction"] ?? "debit",
    transactionType: json["transactionType"] ?? "",
    amountMinor: json["amountMinor"] ?? 0,
    balanceBeforeMinor: json["balanceBeforeMinor"] ?? 0,
    balanceAfterMinor: json["balanceAfterMinor"] ?? 0,
    currency: json["currency"] ?? "MXN",
    paymentMethod: json["paymentMethod"],
    referenceId: json["referenceId"],
    storeName: json["storeName"],
    status: json["status"] ?? "pending",
    relatedOrder: json["relatedOrder"] == null ? null : RelatedOrder.fromJson(json["relatedOrder"]),
    metadata: json["metadata"] == null ? null : Map<String, dynamic>.from(json["metadata"]),
    createdAt: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
  );
}

class WalletLedgerResponse {
  List<WalletLedgerEntry> items;
  Pagination pagination;

  WalletLedgerResponse({required this.items, required this.pagination});

  factory WalletLedgerResponse.fromJson(Map<String, dynamic> json) => WalletLedgerResponse(
    items: (json["items"] as List? ?? []).map((item) => WalletLedgerEntry.fromJson(item)).toList(),
    pagination: Pagination.fromJson(json["pagination"] ?? {}),
  );
}

class WalletTopUpIntent {
  String id;
  int amountMinor;
  String currency;
  String provider;
  String status;
  String referenceId;
  DateTime createdAt;

  WalletTopUpIntent({
    required this.id,
    required this.amountMinor,
    required this.currency,
    required this.provider,
    required this.status,
    required this.referenceId,
    required this.createdAt,
  });

  factory WalletTopUpIntent.fromJson(Map<String, dynamic> json) => WalletTopUpIntent(
    id: json["_id"] ?? json["id"] ?? "",
    amountMinor: json["amountMinor"] ?? 0,
    currency: json["currency"] ?? "MXN",
    provider: json["provider"] ?? "manual",
    status: json["status"] ?? "pending",
    referenceId: json["referenceId"] ?? "",
    createdAt: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
  );
}

class WalletGiftResult {
  String recipientName;
  String recipientEmail;

  WalletGiftResult({required this.recipientName, required this.recipientEmail});

  factory WalletGiftResult.fromJson(Map<String, dynamic> json) {
    final recipient = json["recipient"] ?? {};
    return WalletGiftResult(
      recipientName: recipient["fullName"] ?? "",
      recipientEmail: recipient["email"] ?? "",
    );
  }
}
