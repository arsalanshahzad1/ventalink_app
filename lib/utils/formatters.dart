import 'package:intl/intl.dart';
import 'package:ventalink_mobile/network/api_endpoints.dart';

String formatMoney(int amountMinor, String currency) {
  final formatter = NumberFormat.currency(symbol: "\$", decimalDigits: 2);
  return "${formatter.format(amountMinor / 100)} $currency";
}

String formatDate(DateTime date) {
  return DateFormat("MMM d, yyyy · h:mm a").format(date);
}

String timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);

  if (diff.inMinutes < 1) return "Just now";
  if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
  if (diff.inHours < 24) return "${diff.inHours}h ago";
  if (diff.inDays < 7) return "${diff.inDays}d ago";

  return DateFormat("MMM d").format(date);
}

String resolveImageUrl(String? path) {
  if (path == null || path.isEmpty) return "";
  if (path.startsWith("http://") || path.startsWith("https://") || path.startsWith("data:")) return path;
  if (path.startsWith("/")) return "${GlobalEndpoints.appOrigin}$path";
  return "${GlobalEndpoints.appOrigin}/$path";
}

String statusLabel(String value) {
  return value
      .split("_")
      .map((word) => word.isEmpty ? word : word[0].toUpperCase() + word.substring(1))
      .join(" ");
}
