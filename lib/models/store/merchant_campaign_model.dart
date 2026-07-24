class MerchantCampaign {
  String id;
  String name;
  String type;
  String status;
  int valueBps;
  int valueMinor;
  DateTime? startsAt;
  DateTime? endsAt;
  DateTime createdAt;

  MerchantCampaign({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.valueBps,
    required this.valueMinor,
    this.startsAt,
    this.endsAt,
    required this.createdAt,
  });

  factory MerchantCampaign.fromJson(Map<String, dynamic> json) => MerchantCampaign(
    id: json["id"] ?? json["_id"] ?? "",
    name: json["name"] ?? "",
    type: json["type"] ?? "cashback",
    status: json["status"] ?? "active",
    valueBps: json["valueBps"] ?? 0,
    valueMinor: json["valueMinor"] ?? 0,
    startsAt: json["startsAt"] == null ? null : DateTime.tryParse(json["startsAt"]),
    endsAt: json["endsAt"] == null ? null : DateTime.tryParse(json["endsAt"]),
    createdAt: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
  );
}

class MerchantCampaignSummary {
  String? id;
  String name;
  String type;
  int valueBps;
  int valueMinor;

  MerchantCampaignSummary({this.id, required this.name, required this.type, required this.valueBps, required this.valueMinor});

  factory MerchantCampaignSummary.fromJson(Map<String, dynamic> json) => MerchantCampaignSummary(
    id: json["id"] ?? json["_id"],
    name: json["name"] ?? "",
    type: json["type"] ?? "cashback",
    valueBps: json["valueBps"] ?? 0,
    valueMinor: json["valueMinor"] ?? 0,
  );
}

class MerchantCampaignActivityOrder {
  String id;
  String orderNumber;
  int totalMinor;
  String currency;
  String paymentStatus;
  DateTime createdAt;

  MerchantCampaignActivityOrder({
    required this.id,
    required this.orderNumber,
    required this.totalMinor,
    required this.currency,
    required this.paymentStatus,
    required this.createdAt,
  });

  factory MerchantCampaignActivityOrder.fromJson(Map<String, dynamic> json) => MerchantCampaignActivityOrder(
    id: json["id"] ?? json["_id"] ?? "",
    orderNumber: json["orderNumber"] ?? "",
    totalMinor: json["totalMinor"] ?? 0,
    currency: json["currency"] ?? "MXN",
    paymentStatus: json["paymentStatus"] ?? "",
    createdAt: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
  );
}

class MerchantCampaignActivity {
  String id;
  String transactionType;
  int amountMinor;
  String currency;
  String? referenceId;
  String status;
  DateTime createdAt;
  MerchantCampaignSummary? campaign;
  MerchantCampaignActivityOrder? order;

  MerchantCampaignActivity({
    required this.id,
    required this.transactionType,
    required this.amountMinor,
    required this.currency,
    this.referenceId,
    required this.status,
    required this.createdAt,
    this.campaign,
    this.order,
  });

  factory MerchantCampaignActivity.fromJson(Map<String, dynamic> json) => MerchantCampaignActivity(
    id: json["id"] ?? json["_id"] ?? "",
    transactionType: json["transactionType"] ?? "",
    amountMinor: json["amountMinor"] ?? 0,
    currency: json["currency"] ?? "MXN",
    referenceId: json["referenceId"],
    status: json["status"] ?? "",
    createdAt: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
    campaign: json["campaign"] == null ? null : MerchantCampaignSummary.fromJson(json["campaign"]),
    order: json["order"] == null ? null : MerchantCampaignActivityOrder.fromJson(json["order"]),
  );
}
