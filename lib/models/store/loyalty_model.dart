class LoyaltyBranding {
  String backgroundColor;
  String foregroundColor;
  String labelColor;
  String logoUrl;

  LoyaltyBranding({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.labelColor,
    required this.logoUrl,
  });

  factory LoyaltyBranding.fromJson(Map<String, dynamic>? json) {
    final data = json ?? {};
    return LoyaltyBranding(
      backgroundColor: data["backgroundColor"] ?? "#0EA5E9",
      foregroundColor: data["foregroundColor"] ?? "#FFFFFF",
      labelColor: data["labelColor"] ?? "#FFFFFF",
      logoUrl: data["logoUrl"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "backgroundColor": backgroundColor,
    "foregroundColor": foregroundColor,
    "labelColor": labelColor,
    if (logoUrl.isNotEmpty) "logoUrl": logoUrl,
  };
}

class LoyaltyProgram {
  String id;
  String storeId;
  String name;
  String status;
  int stampsRequired;
  String rewardDescription;
  int couponValidityDays;
  LoyaltyBranding branding;

  LoyaltyProgram({
    required this.id,
    required this.storeId,
    required this.name,
    required this.status,
    required this.stampsRequired,
    required this.rewardDescription,
    required this.couponValidityDays,
    required this.branding,
  });

  factory LoyaltyProgram.fromJson(Map<String, dynamic> json) => LoyaltyProgram(
    id: json["id"] ?? json["_id"] ?? "",
    storeId: json["storeId"] ?? "",
    name: json["name"] ?? "",
    status: json["status"] ?? "active",
    stampsRequired: json["stampsRequired"] ?? 10,
    rewardDescription: json["rewardDescription"] ?? "",
    couponValidityDays: json["couponValidityDays"] ?? 30,
    branding: LoyaltyBranding.fromJson(json["branding"]),
  );
}

class LoyaltyCouponCustomer {
  String? name;
  String? email;

  LoyaltyCouponCustomer({this.name, this.email});

  factory LoyaltyCouponCustomer.fromJson(Map<String, dynamic>? json) {
    if (json == null) return LoyaltyCouponCustomer();
    return LoyaltyCouponCustomer(name: json["name"], email: json["email"]);
  }
}

class LoyaltyCoupon {
  String id;
  String code;
  String status;
  String rewardDescription;
  DateTime? issuedAt;
  DateTime? expiresAt;
  DateTime? redeemedAt;
  LoyaltyCouponCustomer? customer;

  LoyaltyCoupon({
    required this.id,
    required this.code,
    required this.status,
    required this.rewardDescription,
    this.issuedAt,
    this.expiresAt,
    this.redeemedAt,
    this.customer,
  });

  factory LoyaltyCoupon.fromJson(Map<String, dynamic> json) => LoyaltyCoupon(
    id: json["id"] ?? json["_id"] ?? "",
    code: json["code"] ?? "",
    status: json["status"] ?? "issued",
    rewardDescription: json["rewardDescription"] ?? "",
    issuedAt: json["issuedAt"] == null ? null : DateTime.tryParse(json["issuedAt"]),
    expiresAt: json["expiresAt"] == null ? null : DateTime.tryParse(json["expiresAt"]),
    redeemedAt: json["redeemedAt"] == null ? null : DateTime.tryParse(json["redeemedAt"]),
    customer: json["customer"] == null ? null : LoyaltyCouponCustomer.fromJson(json["customer"]),
  );
}
