import 'package:flutter/material.dart';
import 'package:ventalink_mobile/models/wallet_model.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/utils/formatters.dart';

class LedgerEntryTile extends StatelessWidget {
  final WalletLedgerEntry entry;

  const LedgerEntryTile({super.key, required this.entry});

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textGrey, fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12, color: AppColors.textDark))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = entry.isCredit;
    final color = isCredit ? const Color(0xFF16A34A) : const Color(0xFF2563EB);
    final typeLabel = entry.isGift ? "Gift" : statusLabel(entry.transactionType);

    final giftCounterparty = entry.isGift
        ? (isCredit ? entry.senderName ?? entry.senderEmail : entry.recipientName ?? entry.recipientEmail)
        : null;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 4),
        childrenPadding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
        leading: Container(
          height: 40,
          width: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(isCredit ? Icons.arrow_downward : Icons.arrow_upward, color: color, size: 18),
        ),
        title: Text(typeLabel, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        subtitle: Text(timeAgo(entry.createdAt), style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${isCredit ? "+" : "-"}${formatMoney(entry.amountMinor, entry.currency)}",
              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
            ),
            Text(statusLabel(entry.status), style: const TextStyle(fontSize: 10, color: AppColors.textGrey)),
          ],
        ),
        children: [
          if (giftCounterparty != null) _detailRow(isCredit ? "From" : "To", giftCounterparty),
          if (entry.giftMessage != null && entry.giftMessage!.trim().isNotEmpty) _detailRow("Message", entry.giftMessage!),
          _detailRow("Balance after", formatMoney(entry.balanceAfterMinor, entry.currency)),
          if (entry.paymentMethod != null) _detailRow("Payment method", statusLabel(entry.paymentMethod!)),
          if (entry.relatedOrder != null) _detailRow("Order", entry.relatedOrder!.orderNumber),
          if (entry.storeName != null) _detailRow("Store", entry.storeName!),
          _detailRow("Timestamp", formatDate(entry.createdAt)),
        ],
      ),
    );
  }
}
