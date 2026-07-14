import 'package:ventalink_mobile/models/pagination_model.dart';

class AppNotification {
  String id;
  String title;
  String description;
  String kind;
  bool isRead;
  String to;
  DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.kind,
    required this.isRead,
    required this.to,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: json["id"] ?? "",
    title: json["title"] ?? "",
    description: json["description"] ?? "",
    kind: json["kind"] ?? "account",
    isRead: json["isRead"] ?? false,
    to: json["to"] ?? "",
    createdAt: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
  );
}

class NotificationsResponse {
  List<AppNotification> items;
  int unreadCount;
  Pagination pagination;

  NotificationsResponse({required this.items, required this.unreadCount, required this.pagination});

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) => NotificationsResponse(
    items: (json["items"] as List? ?? []).map((item) => AppNotification.fromJson(item)).toList(),
    unreadCount: json["unreadCount"] ?? 0,
    pagination: Pagination.fromJson(json["pagination"] ?? {}),
  );
}
