import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/store/merchant_campaigns_controller.dart';
import 'package:ventalink_mobile/models/store/merchant_campaign_model.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/utils/formatters.dart';
import 'package:ventalink_mobile/utils/prompts.dart';
import 'package:ventalink_mobile/widgets/custom_button.dart';

class CampaignsTab extends StatefulWidget {
  const CampaignsTab({super.key});

  @override
  State<CampaignsTab> createState() => _CampaignsTabState();
}

class _CampaignsTabState extends State<CampaignsTab> {
  final merchantCampaignsController = Get.find<MerchantCampaignsController>();

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
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark))),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case "active":
        return const Color(0xFF16A34A);
      case "paused":
        return AppColors.textGrey;
      default:
        return AppColors.error;
    }
  }

  Widget _campaignTile(MerchantCampaign campaign) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(campaign.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  "${statusLabel(campaign.type)} · ${campaign.valueBps > 0 ? "${campaign.valueBps / 100}%" : formatMoney(campaign.valueMinor, "MXN")}",
                  style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _cycleStatus(campaign),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: _statusColor(campaign.status).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
              child: Text(statusLabel(campaign.status), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _statusColor(campaign.status))),
            ),
          ),
        ],
      ),
    );
  }

  void _cycleStatus(MerchantCampaign campaign) {
    final next = campaign.status == "active" ? "paused" : "active";
    merchantCampaignsController.updateCampaign(campaign.id, {"status": next});
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => RefreshIndicator(
        onRefresh: () async {
          await merchantCampaignsController.loadCampaigns();
          await merchantCampaignsController.loadActivity();
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _sectionCard(
              title: "Reward Campaigns",
              icon: Icons.campaign_outlined,
              child: Column(
                children: [
                  if (merchantCampaignsController.isLoading.value)
                    const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator()))
                  else if (merchantCampaignsController.campaigns.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text("No campaigns yet.", style: TextStyle(color: AppColors.textGrey))),
                    )
                  else
                    ...merchantCampaignsController.campaigns.map(_campaignTile),
                  const SizedBox(height: 8),
                  CustomButton(label: "New Campaign", onPressed: () => _showCreateCampaignSheet(context), height: 46),
                ],
              ),
            ),
            _sectionCard(
              title: "Activity",
              icon: Icons.receipt_long_outlined,
              child: merchantCampaignsController.isLoadingActivity.value
                  ? const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator()))
                  : merchantCampaignsController.activity.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text("No campaign activity yet.", style: TextStyle(color: AppColors.textGrey))),
                    )
                  : Column(
                      children: merchantCampaignsController.activity
                          .map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(entry.campaign?.name ?? statusLabel(entry.transactionType), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                        if (entry.order != null)
                                          Text("Order ${entry.order!.orderNumber}", style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                                      ],
                                    ),
                                  ),
                                  Text("+${formatMoney(entry.amountMinor, entry.currency)}", style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateCampaignSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CreateCampaignSheet(),
    );
  }
}

class _CreateCampaignSheet extends StatefulWidget {
  const _CreateCampaignSheet();

  @override
  State<_CreateCampaignSheet> createState() => _CreateCampaignSheetState();
}

class _CreateCampaignSheetState extends State<_CreateCampaignSheet> {
  final merchantCampaignsController = Get.find<MerchantCampaignsController>();
  final nameController = TextEditingController();
  final valueController = TextEditingController();
  String _type = "cashback";

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

  Future<void> _submit() async {
    final name = nameController.text.trim();
    final value = double.tryParse(valueController.text.trim());

    if (name.isEmpty) {
      Prompts.showSnackBar("Enter a campaign name");
      return;
    }
    if (value == null || value <= 0) {
      Prompts.showSnackBar("Enter a valid value");
      return;
    }

    final body = {
      "name": name,
      "type": _type,
      if (_type == "cashback") "valueBps": (value * 100).round() else "valueMinor": (value * 100).round(),
    };

    final success = await merchantCampaignsController.createCampaign(body);
    if (success && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)))),
            const SizedBox(height: 16),
            const Text("New Campaign", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(height: 16),
            TextField(controller: nameController, decoration: _fieldDecoration("Campaign name")),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: _fieldDecoration("Type"),
              items: const [
                DropdownMenuItem(value: "cashback", child: Text("Cashback")),
                DropdownMenuItem(value: "reward", child: Text("Reward")),
                DropdownMenuItem(value: "promotional_credit", child: Text("Promotional credit")),
              ],
              onChanged: (value) => setState(() => _type = value ?? "cashback"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: valueController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _fieldDecoration(_type == "cashback" ? "Cashback %, e.g. 5" : "Amount, e.g. 20.00"),
            ),
            const SizedBox(height: 16),
            Obx(() => CustomButton(label: "Create Campaign", isLoading: merchantCampaignsController.isSaving.value, onPressed: _submit)),
          ],
        ),
      ),
    );
  }
}
