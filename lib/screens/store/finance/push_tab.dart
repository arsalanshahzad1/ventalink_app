import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/store/push_campaigns_controller.dart';
import 'package:ventalink_mobile/models/store/push_campaign_model.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/utils/formatters.dart';
import 'package:ventalink_mobile/utils/prompts.dart';
import 'package:ventalink_mobile/widgets/custom_button.dart';

class PushTab extends StatefulWidget {
  const PushTab({super.key});

  @override
  State<PushTab> createState() => _PushTabState();
}

class _PushTabState extends State<PushTab> {
  final pushCampaignsController = Get.find<PushCampaignsController>();
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  final linkController = TextEditingController();
  String _audience = "store_customers";

  @override
  void initState() {
    super.initState();
    pushCampaignsController.loadCampaigns();
  }

  Widget _sectionCard({required String title, required Widget child, IconData? icon}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[Icon(icon, size: 18, color: AppColors.primary), const SizedBox(width: 8)],
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textGrey),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  Map<String, dynamic> _payload() => {
    "title": titleController.text.trim(),
    "body": bodyController.text.trim(),
    "targetAudience": _audience,
    "sendMode": "now",
    if (linkController.text.trim().isNotEmpty) "link": linkController.text.trim(),
  };

  Future<void> _estimate() async {
    if (titleController.text.trim().isEmpty || bodyController.text.trim().isEmpty) {
      Prompts.showSnackBar("Enter a title and message first");
      return;
    }
    await pushCampaignsController.estimateCampaign(_payload());
  }

  Future<void> _send() async {
    if (titleController.text.trim().isEmpty || bodyController.text.trim().isEmpty) {
      Prompts.showSnackBar("Enter a title and message");
      return;
    }
    final success = await pushCampaignsController.createCampaign(_payload());
    if (success) {
      titleController.clear();
      bodyController.clear();
      linkController.clear();
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case "sent":
        return const Color(0xFF16A34A);
      case "rejected":
      case "failed":
        return AppColors.error;
      default:
        return AppColors.textGrey;
    }
  }

  Widget _campaignTile(PushCampaign campaign) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(campaign.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: _statusColor(campaign.status).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                child: Text(statusLabel(campaign.status), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _statusColor(campaign.status))),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(campaign.body, style: const TextStyle(fontSize: 12, color: AppColors.textGrey), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Text("${campaign.deliveredCount}/${campaign.deviceCount} delivered", style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => RefreshIndicator(
        onRefresh: pushCampaignsController.loadCampaigns,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _sectionCard(
              title: "New Push Notification",
              icon: Icons.notifications_active_outlined,
              child: Column(
                children: [
                  TextField(controller: titleController, maxLength: 100, decoration: _fieldDecoration("Title")),
                  TextField(controller: bodyController, maxLength: 240, maxLines: 3, decoration: _fieldDecoration("Message")),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: _audience,
                    decoration: _fieldDecoration("Audience"),
                    items: const [
                      DropdownMenuItem(value: "store_customers", child: Text("My store's customers")),
                      DropdownMenuItem(value: "all_customers", child: Text("All customers")),
                    ],
                    onChanged: (value) => setState(() => _audience = value ?? "store_customers"),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: linkController, decoration: _fieldDecoration("Link (optional)")),
                  const SizedBox(height: 14),
                  if (pushCampaignsController.estimate.value != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          "${pushCampaignsController.estimate.value!.deviceCount} devices · Fee: ${formatMoney(pushCampaignsController.estimate.value!.totalFeeMinor, "MXN")}",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: pushCampaignsController.isEstimating.value ? null : _estimate,
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: const BorderSide(color: AppColors.border)),
                          child: const Text("Estimate Fee"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomButton(label: "Send Now", isLoading: pushCampaignsController.isSubmitting.value, onPressed: _send, height: 46),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _sectionCard(
              title: "Recent Campaigns",
              icon: Icons.history,
              child: pushCampaignsController.isLoading.value
                  ? const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator()))
                  : pushCampaignsController.campaigns.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text("No push campaigns yet.", style: TextStyle(color: AppColors.textGrey))),
                    )
                  : Column(children: pushCampaignsController.campaigns.map(_campaignTile).toList()),
            ),
          ],
        ),
      ),
    );
  }
}
