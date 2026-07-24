class MerchantProduct {
  String id;
  String storeId;
  String ownerId;
  String name;
  String? description;
  int priceMinor;
  String currency;
  String? imageUrl;
  bool isActive;
  bool walletEligible;
  int? position;
  DateTime? createdAt;
  DateTime? updatedAt;

  MerchantProduct({
    required this.id,
    required this.storeId,
    required this.ownerId,
    required this.name,
    this.description,
    required this.priceMinor,
    required this.currency,
    this.imageUrl,
    required this.isActive,
    required this.walletEligible,
    this.position,
    this.createdAt,
    this.updatedAt,
  });

  factory MerchantProduct.fromJson(Map<String, dynamic> json) => MerchantProduct(
    id: json["id"] ?? json["_id"] ?? "",
    storeId: json["storeId"] ?? "",
    ownerId: json["ownerId"] ?? "",
    name: json["name"] ?? "",
    description: json["description"],
    priceMinor: json["priceMinor"] ?? 0,
    currency: json["currency"] ?? "MXN",
    imageUrl: json["imageUrl"],
    isActive: json["isActive"] ?? true,
    walletEligible: json["walletEligible"] ?? false,
    position: json["position"],
    createdAt: json["createdAt"] == null ? null : DateTime.tryParse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.tryParse(json["updatedAt"]),
  );
}

class MerchantProductResponse {
  List<MerchantProduct> items;

  MerchantProductResponse({required this.items});

  factory MerchantProductResponse.fromJson(Map<String, dynamic> json) => MerchantProductResponse(
    items: (json["items"] as List? ?? []).map((item) => MerchantProduct.fromJson(item)).toList(),
  );
}
