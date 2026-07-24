class StoreDaySchedule {
  String day;
  bool isOpen;
  String openTime;
  String closeTime;

  StoreDaySchedule({
    required this.day,
    required this.isOpen,
    required this.openTime,
    required this.closeTime,
  });

  factory StoreDaySchedule.fromJson(Map<String, dynamic> json) => StoreDaySchedule(
    day: json["day"] ?? "mon",
    isOpen: json["isOpen"] ?? true,
    openTime: json["openTime"] ?? "00:00",
    closeTime: json["closeTime"] ?? "00:00",
  );

  Map<String, dynamic> toJson() => {
    "day": day,
    "isOpen": isOpen,
    "openTime": openTime,
    "closeTime": closeTime,
  };
}

class StoreOperatingHours {
  bool enabled;
  String timezone;
  List<StoreDaySchedule> weeklySchedule;

  StoreOperatingHours({required this.enabled, required this.timezone, required this.weeklySchedule});

  factory StoreOperatingHours.fromJson(Map<String, dynamic>? json) {
    final data = json ?? {};
    return StoreOperatingHours(
      enabled: data["enabled"] ?? false,
      timezone: data["timezone"] ?? "America/Mexico_City",
      weeklySchedule: (data["weeklySchedule"] as List? ?? [])
          .map((e) => StoreDaySchedule.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    "enabled": enabled,
    "timezone": timezone,
    if (weeklySchedule.isNotEmpty) "weeklySchedule": weeklySchedule.map((e) => e.toJson()).toList(),
  };
}

class StoreWalletSettings {
  bool acceptsWalletPayments;
  bool acceptsHybridPayments;
  bool rewardParticipationEnabled;
  List<String> eligibleProductIds;

  StoreWalletSettings({
    required this.acceptsWalletPayments,
    required this.acceptsHybridPayments,
    required this.rewardParticipationEnabled,
    required this.eligibleProductIds,
  });

  factory StoreWalletSettings.fromJson(Map<String, dynamic>? json) {
    final data = json ?? {};
    return StoreWalletSettings(
      acceptsWalletPayments: data["acceptsWalletPayments"] ?? false,
      acceptsHybridPayments: data["acceptsHybridPayments"] ?? false,
      rewardParticipationEnabled: data["rewardParticipationEnabled"] ?? false,
      eligibleProductIds: (data["eligibleProductIds"] as List? ?? []).map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    "acceptsWalletPayments": acceptsWalletPayments,
    "acceptsHybridPayments": acceptsHybridPayments,
    "rewardParticipationEnabled": rewardParticipationEnabled,
  };
}

class StoreLocation {
  double? lat;
  double? lng;

  StoreLocation({this.lat, this.lng});

  factory StoreLocation.fromJson(Map<String, dynamic>? json) {
    final data = json ?? {};
    return StoreLocation(
      lat: (data["lat"] as num?)?.toDouble(),
      lng: (data["lng"] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (lat != null) "lat": lat,
    if (lng != null) "lng": lng,
  };
}

class StoreProfile {
  String id;
  String ownerId;
  String name;
  String slug;
  String? logoUrl;
  String whatsappNumber;
  String tagline;
  String address;
  String city;
  String state;
  String country;
  StoreLocation location;
  String currency;
  bool isActive;
  StoreOperatingHours operatingHours;
  StoreWalletSettings walletSettings;
  DateTime? createdAt;
  DateTime? updatedAt;

  StoreProfile({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.slug,
    this.logoUrl,
    required this.whatsappNumber,
    required this.tagline,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.location,
    required this.currency,
    required this.isActive,
    required this.operatingHours,
    required this.walletSettings,
    this.createdAt,
    this.updatedAt,
  });

  factory StoreProfile.fromJson(Map<String, dynamic> json) => StoreProfile(
    id: json["id"] ?? json["_id"] ?? "",
    ownerId: json["ownerId"] ?? "",
    name: json["name"] ?? "",
    slug: json["slug"] ?? "",
    logoUrl: json["logoUrl"],
    whatsappNumber: json["whatsappNumber"] ?? "",
    tagline: json["tagline"] ?? "",
    address: json["address"] ?? "",
    city: json["city"] ?? "",
    state: json["state"] ?? "",
    country: json["country"] ?? "MX",
    location: StoreLocation.fromJson(json["location"]),
    currency: json["currency"] ?? "MXN",
    isActive: json["isActive"] ?? true,
    operatingHours: StoreOperatingHours.fromJson(json["operatingHours"]),
    walletSettings: StoreWalletSettings.fromJson(json["walletSettings"]),
    createdAt: json["createdAt"] == null ? null : DateTime.tryParse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.tryParse(json["updatedAt"]),
  );
}
