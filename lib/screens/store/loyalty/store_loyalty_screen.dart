import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/store/loyalty_controller.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/utils/formatters.dart';
import 'package:ventalink_mobile/utils/prompts.dart';
import 'package:ventalink_mobile/widgets/custom_button.dart';

class StoreLoyaltyScreen extends StatefulWidget {
  const StoreLoyaltyScreen({super.key});

  @override
  State<StoreLoyaltyScreen> createState() => _StoreLoyaltyScreenState();
}

class _StoreLoyaltyScreenState extends State<StoreLoyaltyScreen> {
  final loyaltyController = Get.find<LoyaltyController>();

  final nameController = TextEditingController();
  final stampsController = TextEditingController(text: "10");
  final rewardController = TextEditingController();
  final validityController = TextEditingController(text: "30");
  final redeemCodeController = TextEditingController();
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    loyaltyController.loadProgram().then((_) => _prefillFromProgram());
    loyaltyController.loadCoupons();
  }

  void _prefillFromProgram() {
    final program = loyaltyController.program.value;
    if (program == null || _prefilled) return;
    _prefilled = true;
    nameController.text = program.name;
    stampsController.text = program.stampsRequired.toString();
    rewardController.text = program.rewardDescription;
    validityController.text = program.couponValidityDays.toString();
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

  Future<void> _saveProgram() async {
    final stamps = int.tryParse(stampsController.text.trim());
    final validity = int.tryParse(validityController.text.trim());

    if (nameController.text.trim().isEmpty) {
      Prompts.showSnackBar("Enter a program name");
      return;
    }
    if (stamps == null || stamps < 2 || stamps > 50) {
      Prompts.showSnackBar("Stamps required must be between 2 and 50");
      return;
    }
    if (rewardController.text.trim().isEmpty) {
      Prompts.showSnackBar("Describe the reward");
      return;
    }

    await loyaltyController.upsertProgram({
      "name": nameController.text.trim(),
      "stampsRequired": stamps,
      "rewardDescription": rewardController.text.trim(),
      if (validity != null) "couponValidityDays": validity,
    });
  }

  Future<void> _redeemCoupon() async {
    final code = redeemCodeController.text.trim();
    if (code.isEmpty) {
      Prompts.showSnackBar("Enter a coupon code");
      return;
    }
    final success = await loyaltyController.redeemCoupon(code);
    if (success) redeemCodeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text("Loyalty Program", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: Obx(() {
        if (loyaltyController.isLoading.value && loyaltyController.program.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        _prefillFromProgram();

        return RefreshIndicator(
          onRefresh: () async {
            await loyaltyController.loadProgram();
            await loyaltyController.loadCoupons();
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _sectionCard(
                title: "Program Settings",
                icon: Icons.card_giftcard_outlined,
                child: Column(
                  children: [
                    TextField(controller: nameController, decoration: _fieldDecoration("Program name, e.g. Coffee Club")),
                    const SizedBox(height: 12),
                    TextField(
                      controller: stampsController,
                      keyboardType: TextInputType.number,
                      decoration: _fieldDecoration("Stamps required (2-50)"),
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: rewardController, decoration: _fieldDecoration("Reward description")),
                    const SizedBox(height: 12),
                    TextField(
                      controller: validityController,
                      keyboardType: TextInputType.number,
                      decoration: _fieldDecoration("Coupon validity in days (1-365)"),
                    ),
                    const SizedBox(height: 14),
                    CustomButton(label: "Save Program", isLoading: loyaltyController.isSaving.value, onPressed: _saveProgram, height: 46),
                  ],
                ),
              ),
              _sectionCard(
                title: "Redeem Coupon",
                icon: Icons.qr_code_scanner_outlined,
                child: Column(
                  children: [
                    TextField(
                      controller: redeemCodeController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: _fieldDecoration("Enter coupon code"),
                    ),
                    const SizedBox(height: 12),
                    CustomButton(label: "Redeem", isLoading: loyaltyController.isRedeeming.value, onPressed: _redeemCoupon, height: 46),
                  ],
                ),
              ),
              _sectionCard(
                title: "Recent Coupons",
                icon: Icons.receipt_outlined,
                child: loyaltyController.isLoadingCoupons.value
                    ? const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator()))
                    : loyaltyController.coupons.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: Text("No coupons yet.", style: TextStyle(color: AppColors.textGrey))),
                      )
                    : Column(
                        children: loyaltyController.coupons
                            .map(
                              (coupon) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(coupon.code, style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: "monospace")),
                                          Text(coupon.rewardDescription, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                                          if (coupon.customer?.name != null)
                                            Text(coupon.customer!.name!, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                                        ],
                                      ),
                                    ),
                                    Text(statusLabel(coupon.status), style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
