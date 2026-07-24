class PushCampaign {
  String id;
  String title;
  String body;
  String targetAudience;
  String status;
  DateTime? scheduledFor;
  int recipientCount;
  int deviceCount;
  int deliveredCount;
  int failedCount;
  int feePerDeviceMinor;
  int totalFeeMinor;
  String? reviewNote;
  String? link;
  DateTime createdAt;
  DateTime? sentAt;

  PushCampaign({
    required this.id,
    required this.title,
    required this.body,
    required this.targetAudience,
    required this.status,
    this.scheduledFor,
    required this.recipientCount,
    required this.deviceCount,
    required this.deliveredCount,
    required this.failedCount,
    required this.feePerDeviceMinor,
    required this.totalFeeMinor,
    this.reviewNote,
    this.link,
    required this.createdAt,
    this.sentAt,
  });

  factory PushCampaign.fromJson(Map<String, dynamic> json) => PushCampaign(
    id: json["id"] ?? json["_id"] ?? "",
    title: json["title"] ?? "",
    body: json["body"] ?? "",
    targetAudience: json["targetAudience"] ?? "store_customers",
    status: json["status"] ?? "draft",
    scheduledFor: json["scheduledFor"] == null ? null : DateTime.tryParse(json["scheduledFor"]),
    recipientCount: json["recipientCount"] ?? 0,
    deviceCount: json["deviceCount"] ?? 0,
    deliveredCount: json["deliveredCount"] ?? 0,
    failedCount: json["failedCount"] ?? 0,
    feePerDeviceMinor: json["feePerDeviceMinor"] ?? 0,
    totalFeeMinor: json["totalFeeMinor"] ?? 0,
    reviewNote: json["reviewNote"],
    link: json["link"],
    createdAt: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
    sentAt: json["sentAt"] == null ? null : DateTime.tryParse(json["sentAt"]),
  );
}

class PushEstimate {
  int recipientCount;
  int deviceCount;
  int feePerDeviceMinor;
  int totalFeeMinor;
  bool approvalRequired;

  PushEstimate({
    required this.recipientCount,
    required this.deviceCount,
    required this.feePerDeviceMinor,
    required this.totalFeeMinor,
    required this.approvalRequired,
  });

  factory PushEstimate.fromJson(Map<String, dynamic> json) => PushEstimate(
    recipientCount: json["recipientCount"] ?? 0,
    deviceCount: json["deviceCount"] ?? 0,
    feePerDeviceMinor: json["feePerDeviceMinor"] ?? 0,
    totalFeeMinor: json["totalFeeMinor"] ?? 0,
    approvalRequired: json["approvalRequired"] ?? false,
  );
}
