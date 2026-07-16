import 'package:ventalink_mobile/models/pagination_model.dart';

class StoreOpenStatus {
  bool isOpenNow;
  String label;
  String todayHours;

  StoreOpenStatus({required this.isOpenNow, required this.label, required this.todayHours});

  factory StoreOpenStatus.fromJson(Map<String, dynamic> json) => StoreOpenStatus(
    isOpenNow: json["isOpenNow"] ?? true,
    label: json["label"] ?? "",
    todayHours: json["todayHours"] ?? "",
  );
}

class StoreWalletSettings {
  bool acceptsWalletPayments;
  bool acceptsHybridPayments;

  StoreWalletSettings({required this.acceptsWalletPayments, required this.acceptsHybridPayments});

  factory StoreWalletSettings.fromJson(Map<String, dynamic> json) => StoreWalletSettings(
    acceptsWalletPayments: json["acceptsWalletPayments"] ?? false,
    acceptsHybridPayments: json["acceptsHybridPayments"] ?? false,
  );
}

class StoreCampaign {
  String id;
  String name;
  String type;
  int valueBps;
  int valueMinor;

  StoreCampaign({required this.id, required this.name, required this.type, required this.valueBps, required this.valueMinor});

  factory StoreCampaign.fromJson(Map<String, dynamic> json) => StoreCampaign(
    id: json["id"] ?? "",
    name: json["name"] ?? "",
    type: json["type"] ?? "",
    valueBps: json["valueBps"] ?? 0,
    valueMinor: json["valueMinor"] ?? 0,
  );
}

class PublicStore {
  String name;
  String slug;
  String logoUrl;
  String tagline;
  String whatsappNumber;
  String? address;
  String? city;
  int productCount;
  StoreOpenStatus? openStatus;
  StoreWalletSettings? walletSettings;
  List<StoreCampaign> campaigns;

  PublicStore({
    required this.name,
    required this.slug,
    required this.logoUrl,
    required this.tagline,
    required this.whatsappNumber,
    this.address,
    this.city,
    this.productCount = 0,
    this.openStatus,
    this.walletSettings,
    this.campaigns = const [],
  });

  factory PublicStore.fromJson(Map<String, dynamic> json) => PublicStore(
    name: json["name"] ?? "",
    slug: json["slug"] ?? "",
    logoUrl: json["logoUrl"] ?? "",
    tagline: json["tagline"] ?? "",
    whatsappNumber: json["whatsappNumber"] ?? "",
    address: json["address"],
    city: json["city"],
    productCount: json["productCount"] ?? 0,
    openStatus: json["openStatus"] == null ? null : StoreOpenStatus.fromJson(json["openStatus"]),
    walletSettings: json["walletSettings"] == null ? null : StoreWalletSettings.fromJson(json["walletSettings"]),
    campaigns: (json["campaigns"] as List? ?? []).map((item) => StoreCampaign.fromJson(item)).toList(),
  );
}

class PublicProduct {
  String id;
  String name;
  String? description;
  int priceMinor;
  String currency;
  String? imageUrl;
  bool isFavorite;
  bool walletEligible;

  PublicProduct({
    required this.id,
    required this.name,
    this.description,
    required this.priceMinor,
    required this.currency,
    this.imageUrl,
    this.isFavorite = false,
    this.walletEligible = false,
  });

  factory PublicProduct.fromJson(Map<String, dynamic> json) => PublicProduct(
    id: json["id"] ?? "",
    name: json["name"] ?? "",
    description: json["description"],
    priceMinor: json["priceMinor"] ?? 0,
    currency: json["currency"] ?? "MXN",
    imageUrl: json["imageUrl"],
    isFavorite: json["isFavorite"] ?? false,
    walletEligible: json["walletEligible"] ?? false,
  );
}

class MarketplaceProduct extends PublicProduct {
  PublicStore store;

  MarketplaceProduct({
    required super.id,
    required super.name,
    super.description,
    required super.priceMinor,
    required super.currency,
    super.imageUrl,
    super.isFavorite,
    super.walletEligible,
    required this.store,
  });

  factory MarketplaceProduct.fromJson(Map<String, dynamic> json) {
    final product = PublicProduct.fromJson(json);
    return MarketplaceProduct(
      id: product.id,
      name: product.name,
      description: product.description,
      priceMinor: product.priceMinor,
      currency: product.currency,
      imageUrl: product.imageUrl,
      isFavorite: product.isFavorite,
      walletEligible: product.walletEligible,
      store: PublicStore.fromJson(json["store"] ?? {}),
    );
  }
}

class StoreDetailResponse {
  PublicStore store;
  List<PublicProduct> products;

  StoreDetailResponse({required this.store, required this.products});

  factory StoreDetailResponse.fromJson(Map<String, dynamic> json) => StoreDetailResponse(
    store: PublicStore.fromJson(json["store"] ?? {}),
    products: (json["products"] as List? ?? []).map((item) => PublicProduct.fromJson(item)).toList(),
  );
}

class MarketplaceResponse {
  List<MarketplaceProduct> products;
  List<PublicStore> stores;
  Pagination pagination;

  MarketplaceResponse({required this.products, required this.stores, required this.pagination});

  factory MarketplaceResponse.fromJson(Map<String, dynamic> json) => MarketplaceResponse(
    products: (json["products"] as List? ?? []).map((item) => MarketplaceProduct.fromJson(item)).toList(),
    stores: (json["stores"] as List? ?? []).map((item) => PublicStore.fromJson(item)).toList(),
    pagination: Pagination.fromJson(json["pagination"] ?? {}),
  );
}
