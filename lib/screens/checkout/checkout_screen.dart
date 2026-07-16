import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ventalink_mobile/controllers/checkout_controller.dart';
import 'package:ventalink_mobile/screens/track_order/track_order_screen.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/utils/formatters.dart';
import 'package:ventalink_mobile/utils/prompts.dart';
import 'package:ventalink_mobile/utils/routing_service.dart';
import 'package:ventalink_mobile/widgets/conekta_terms_modal.dart';
import 'package:ventalink_mobile/widgets/custom_button.dart';

class CheckoutScreen extends StatefulWidget {
  final String slug;
  final Map<String, int> initialCart;

  const CheckoutScreen({super.key, required this.slug, required this.initialCart});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late final String _tag;
  late final CheckoutController checkoutController;
  final notesController = TextEditingController();
  final walletAmountController = TextEditingController();
  final cardNumberController = TextEditingController();
  final cardNameController = TextEditingController();
  final cardExpiryController = TextEditingController();
  final cardCvcController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tag = "${widget.slug}-${DateTime.now().millisecondsSinceEpoch}";
    checkoutController = Get.put(CheckoutController(slug: widget.slug, initialCart: widget.initialCart), tag: _tag);
    checkoutController.init();
  }

  @override
  void dispose() {
    notesController.dispose();
    walletAmountController.dispose();
    cardNumberController.dispose();
    cardNameController.dispose();
    cardExpiryController.dispose();
    cardCvcController.dispose();
    Get.delete<CheckoutController>(tag: _tag);
    super.dispose();
  }

  Map<String, dynamic> _methodMeta(String id) {
    switch (id) {
      case "card":
        return {"label": "Credit / debit card", "desc": "Visa, Mastercard, Amex", "icon": Icons.credit_card_outlined};
      case "bank":
        return {"label": "SPEI", "desc": "Bank transfer", "icon": Icons.account_balance_outlined};
      case "wallet":
        return {
          "label": "Pay with wallet",
          "desc": "${formatMoney(checkoutController.walletBalanceMinor, checkoutController.currency)} wallet balance available",
          "icon": Icons.account_balance_wallet_outlined,
        };
      case "hybrid_card":
        return {"label": "Wallet + card", "desc": "Use wallet balance plus a card", "icon": Icons.call_split};
      case "hybrid_spei":
        return {"label": "Wallet + SPEI", "desc": "Use wallet balance plus bank transfer", "icon": Icons.call_split};
      case "hybrid_conekta":
        return {"label": "Wallet + Conekta", "desc": "Use wallet balance plus Conekta card", "icon": Icons.call_split};
      default:
        return {"label": id, "desc": "", "icon": Icons.payment_outlined};
    }
  }

  Future<void> _contactSeller(String whatsappNumber) async {
    final digitsOnly = whatsappNumber.split("").where((char) => "0123456789".contains(char)).join();
    if (digitsOnly.isEmpty) return;
    final uri = Uri.parse("https://wa.me/$digitsOnly");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _submitNative() async {
    final ok = await checkoutController.submitOrder();
    if (!ok && checkoutController.checkoutError.value.isNotEmpty) {
      Prompts.showSnackBar(checkoutController.checkoutError.value);
    }
  }

  String _formatCardNumber(String value) {
    final digits = value.replaceAll(RegExp(r"\D"), "");
    final trimmed = digits.length > 16 ? digits.substring(0, 16) : digits;
    final groups = <String>[];
    for (var i = 0; i < trimmed.length; i += 4) {
      groups.add(trimmed.substring(i, i + 4 > trimmed.length ? trimmed.length : i + 4));
    }
    return groups.join(" ");
  }

  String _formatExpiry(String value) {
    final digits = value.replaceAll(RegExp(r"\D"), "");
    final trimmed = digits.length > 4 ? digits.substring(0, 4) : digits;
    if (trimmed.length <= 2) return trimmed;
    return "${trimmed.substring(0, 2)}/${trimmed.substring(2)}";
  }

  void _applyFormatted(TextEditingController controller, String formatted) {
    controller.value = TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }

  Future<void> _submitCardPayment() async {
    final number = cardNumberController.text.replaceAll(" ", "");
    final name = cardNameController.text.trim();
    final expParts = cardExpiryController.text.split("/");
    final expMonth = expParts.isNotEmpty ? expParts[0] : "";
    final expYear = expParts.length > 1 ? expParts[1] : "";
    final cvc = cardCvcController.text.trim();

    if (number.length < 12 || name.isEmpty || expMonth.length != 2 || expYear.length < 2 || cvc.length < 3) {
      Prompts.showSnackBar("Enter complete card details.");
      return;
    }

    if (!checkoutController.hasAgreedCardTerms.value) {
      final agreed = await showDialog<bool>(context: context, builder: (_) => const ConektaTermsModal());
      if (agreed != true) return;
      checkoutController.hasAgreedCardTerms.value = true;
    }

    final ok = await checkoutController.tokenizeAndSubmitCard(number: number, name: name, expMonth: expMonth, expYear: expYear, cvc: cvc);
    if (!ok && checkoutController.checkoutError.value.isNotEmpty) {
      Prompts.showSnackBar(checkoutController.checkoutError.value);
    }
  }

  Widget _stepDots() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final n = index + 1;
            final active = n <= checkoutController.step.value;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: active ? 28 : 8,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _storeHeader() {
    final store = checkoutController.store.value!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage: store.logoUrl.isNotEmpty ? NetworkImage(resolveImageUrl(store.logoUrl)) : null,
            child: store.logoUrl.isEmpty
                ? Text(store.name.isNotEmpty ? store.name[0].toUpperCase() : "?", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 18))
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("ORDERING FROM", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textGrey, letterSpacing: 0.6)),
                Text(store.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                if (store.tagline.isNotEmpty) Text(store.tagline, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _step1() {
    return Obx(() {
      final cartItems = checkoutController.cartItems;
      final remaining = checkoutController.storeProducts.where((product) => (checkoutController.cart[product.id] ?? 0) == 0).toList();

      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          _storeHeader(),
          const SizedBox(height: 20),
          const Text("Review order", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                ...cartItems.map(
                  (product) => Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                              ? Image.network(resolveImageUrl(product.imageUrl), height: 64, width: 64, fit: BoxFit.cover)
                              : Container(height: 64, width: 64, color: AppColors.background, child: const Icon(Icons.image_outlined, color: AppColors.textGrey)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(formatMoney(product.priceMinor, product.currency), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primary)),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                iconSize: 18,
                                onPressed: () => checkoutController.updateQuantity(product.id, (checkoutController.cart[product.id] ?? 0) - 1),
                                icon: const Icon(Icons.remove),
                              ),
                              Text("${checkoutController.cart[product.id] ?? 0}", style: const TextStyle(fontWeight: FontWeight.w700)),
                              IconButton(
                                iconSize: 18,
                                onPressed: (checkoutController.cart[product.id] ?? 0) >= 99
                                    ? null
                                    : () => checkoutController.updateQuantity(product.id, (checkoutController.cart[product.id] ?? 0) + 1),
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (remaining.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Add more from this store", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        const SizedBox(height: 10),
                        ...remaining.map(
                          (product) => GestureDetector(
                            onTap: () => checkoutController.updateQuantity(product.id, 1),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                                        ? Image.network(resolveImageUrl(product.imageUrl), height: 36, width: 36, fit: BoxFit.cover)
                                        : Container(height: 36, width: 36, color: AppColors.background),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                                  const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(color: AppColors.background),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total", style: TextStyle(fontWeight: FontWeight.w700)),
                      Text(formatMoney(checkoutController.totalMinor, checkoutController.currency), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!checkoutController.isStoreOpen) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(16)),
              child: Text(
                "Store closed. Today's hours: ${checkoutController.store.value?.openStatus?.todayHours ?? "Closed"}",
                style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
          const SizedBox(height: 20),
          CustomButton(
            label: checkoutController.isStoreOpen ? "Continue to payment" : "Store closed",
            onPressed: (!checkoutController.isStoreOpen || cartItems.isEmpty)
                ? null
                : () => checkoutController.step.value = 2,
          ),
          if (checkoutController.store.value!.campaigns.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.card_giftcard_outlined, color: AppColors.primary, size: 18),
                      SizedBox(width: 8),
                      Text("Rewards available", style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...checkoutController.store.value!.campaigns.map(
                    (campaign) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(campaign.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                          Text(
                            campaign.valueMinor > 0
                                ? formatMoney(campaign.valueMinor, checkoutController.currency)
                                : "${campaign.valueBps / 100}%",
                            style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _step2() {
    return Obx(() {
      final user = checkoutController.currentUser.value;
      final needsToken = checkoutController.needsCardToken;
      final canProceed = checkoutController.isStoreOpen &&
          checkoutController.cartItems.isNotEmpty &&
          !checkoutController.walletAmountInvalid &&
          !(checkoutController.method.value == "wallet" && checkoutController.walletBalanceMinor < checkoutController.totalMinor) &&
          !checkoutController.isSubmitting.value &&
          !checkoutController.isTokenizing.value;

      String payLabel;
      if (checkoutController.isTokenizing.value) {
        payLabel = "Verifying card...";
      } else if (checkoutController.isSubmitting.value) {
        payLabel = "Processing...";
      } else if (needsToken) {
        payLabel = "Pay Now";
      } else if (checkoutController.method.value == "wallet") {
        payLabel = "Pay with wallet";
      } else if (checkoutController.isHybridMethod(checkoutController.method.value)) {
        payLabel = "Pay with ${(CheckoutController.hybridLabels[checkoutController.method.value] ?? "hybrid").toLowerCase()}";
      } else {
        payLabel = "Generate SPEI";
      }

      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: checkoutController.store.value!.logoUrl.isNotEmpty ? NetworkImage(resolveImageUrl(checkoutController.store.value!.logoUrl)) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Checkout", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                      Text("${checkoutController.store.value!.name} · Complete your details and payment", style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text("Account Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text("Using your saved account information for checkout.", style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.fullName ?? "", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 4),
                Text(user?.email ?? "", style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                const SizedBox(height: 2),
                Text(user?.phone?.isNotEmpty == true ? user!.phone! : "Not provided", style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: notesController,
            onChanged: (value) => checkoutController.notesText.value = value,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Order notes (optional)",
              hintStyle: const TextStyle(color: AppColors.textGrey),
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
            ),
          ),
          const SizedBox(height: 24),
          const Text("Payment Method", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text("Select how you want to pay", style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
          const SizedBox(height: 12),
          ...checkoutController.visibleMethodIds.map((id) {
            final meta = _methodMeta(id);
            final selected = checkoutController.method.value == id;
            return GestureDetector(
              onTap: () => checkoutController.method.value = id,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary.withValues(alpha: 0.06) : AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 1.5 : 1),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: selected ? AppColors.primaryGradient : null,
                        color: selected ? null : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(meta["icon"] as IconData, color: selected ? Colors.white : AppColors.textDark, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(meta["label"] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          Text(meta["desc"] as String, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                        ],
                      ),
                    ),
                    Icon(selected ? Icons.check_circle : Icons.circle_outlined, color: selected ? AppColors.primary : AppColors.border),
                  ],
                ),
              ),
            );
          }),
          if (checkoutController.method.value == "wallet") ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Wallet balance", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      Text("${formatMoney(checkoutController.walletBalanceMinor, checkoutController.currency)} available", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                  if (checkoutController.walletBalanceMinor < checkoutController.totalMinor) ...[
                    const SizedBox(height: 6),
                    const Text("Wallet balance is too low for this order.", style: TextStyle(color: AppColors.error, fontSize: 12)),
                  ],
                ],
              ),
            ),
          ],
          if (checkoutController.isHybridMethod(checkoutController.method.value)) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Choose how much wallet balance to use first. We will charge the rest to your "
                    "${checkoutController.method.value == "hybrid_spei" ? "bank transfer" : "card"}.",
                    style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: walletAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) => checkoutController.walletAmountText.value = value,
                    decoration: InputDecoration(
                      hintText: "25.00",
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Wallet", style: TextStyle(fontSize: 10, color: AppColors.textGrey)),
                              Text(formatMoney(checkoutController.walletAmountMinor, checkoutController.currency), style: const TextStyle(fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("External", style: TextStyle(fontSize: 10, color: AppColors.textGrey)),
                              Text(
                                formatMoney((checkoutController.totalMinor - checkoutController.walletAmountMinor).clamp(0, checkoutController.totalMinor), checkoutController.currency),
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (checkoutController.walletAmountInvalid) ...[
                    const SizedBox(height: 8),
                    const Text("Enter a wallet amount within your available balance.", style: TextStyle(color: AppColors.error, fontSize: 12)),
                  ],
                ],
              ),
            ),
          ],
          if (needsToken) ...[
            const SizedBox(height: 20),
            const Text("Card Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              checkoutController.isHybridMethod(checkoutController.method.value)
                  ? "Enter card details for the remaining ${formatMoney((checkoutController.totalMinor - checkoutController.walletAmountMinor).clamp(0, checkoutController.totalMinor), checkoutController.currency)}."
                  : "Enter your card information securely",
              style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: Column(
                children: [
                  TextField(
                    controller: cardNumberController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _applyFormatted(cardNumberController, _formatCardNumber(value)),
                    decoration: _cardInputDecoration("1234 5678 9012 3456"),
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: cardNameController, decoration: _cardInputDecoration("Cardholder Name")),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: cardExpiryController,
                          keyboardType: TextInputType.number,
                          onChanged: (value) => _applyFormatted(cardExpiryController, _formatExpiry(value)),
                          decoration: _cardInputDecoration("MM/YY"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: cardCvcController,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          maxLength: 4,
                          onChanged: (value) {
                            final digits = value.replaceAll(RegExp(r"\D"), "");
                            if (digits != value) _applyFormatted(cardCvcController, digits);
                          },
                          decoration: _cardInputDecoration("CVC").copyWith(counterText: ""),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Builder(builder: (context) {
                    final baseAmount = (checkoutController.totalMinor - checkoutController.walletAmountMinor).clamp(0, checkoutController.totalMinor) / 100;
                    final taxAmount = double.parse((baseAmount * 0.03).toStringAsFixed(2));
                    final totalAmount = double.parse((baseAmount + taxAmount).toStringAsFixed(2));
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          _amountRow("Base Amount", baseAmount),
                          _amountRow("Tax (3%)", taxAmount),
                          const Divider(height: 16),
                          _amountRow("Total", totalAmount, bold: true),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
          if (checkoutController.checkoutError.value.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(12)),
              child: Text(checkoutController.checkoutError.value, style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 12)),
            ),
          ],
          const SizedBox(height: 20),
          CustomButton(
            label: payLabel,
            isLoading: checkoutController.isSubmitting.value || checkoutController.isTokenizing.value,
            onPressed: !canProceed ? null : () => needsToken ? _submitCardPayment() : _submitNative(),
          ),
        ],
      );
    });
  }

  InputDecoration _cardInputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.textGrey),
    filled: true,
    fillColor: AppColors.background,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
  );

  Widget _amountRow(String label, double amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w500)),
          Text("\$${amount.toStringAsFixed(2)}", style: TextStyle(fontSize: bold ? 15 : 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _step3() {
    return Obx(() {
      final order = checkoutController.orderResult.value?.order;
      final payment = checkoutController.orderResult.value?.payment;
      final store = checkoutController.store.value;

      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              backgroundImage: store != null && store.logoUrl.isNotEmpty ? NetworkImage(resolveImageUrl(store.logoUrl)) : null,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              height: 72,
              width: 72,
              decoration: const BoxDecoration(color: Color(0xFFDCFCE7), shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Color(0xFF15803D), size: 34),
            ),
          ),
          const SizedBox(height: 20),
          const Center(child: Text("Order confirmed!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800))),
          const SizedBox(height: 6),
          const Center(child: Text("Your order has been created successfully.", style: TextStyle(color: AppColors.textGrey))),
          if (order != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("ORDER NUMBER", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textGrey, letterSpacing: 0.6)),
                            const SizedBox(height: 4),
                            Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: order.isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          order.isPaid ? "Receipt ready" : "Status saved",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: order.isPaid ? const Color(0xFF15803D) : const Color(0xFFB45309)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text("Use this number, your email, or your phone later to search the bill and order status.", style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => RoutingService.push(TrackOrderScreen(initialQuery: order.orderNumber)),
                          icon: const Icon(Icons.schedule, size: 16),
                          label: const Text("Track order"),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          if (checkoutController.usesSpei && payment?.bank != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Bank", style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
                  Text(payment!.bank!.bank ?? "", style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  const Text("CLABE", style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
                  Row(
                    children: [
                      Expanded(child: Text(payment.bank!.clabe ?? "", style: const TextStyle(fontWeight: FontWeight.w700))),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: payment.bank!.clabe ?? ""));
                          Prompts.showSnackBar("CLABE copied");
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (store != null && store.whatsappNumber.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _contactSeller(store.whatsappNumber),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text("Contact seller"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: const Text("Checkout", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
      ),
      body: Obx(() {
        if (checkoutController.isLoadingStore.value && checkoutController.store.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (checkoutController.storeLoadFailed.value || checkoutController.store.value == null) {
          return const Center(child: Text("Could not load this store.", style: TextStyle(color: AppColors.textGrey)));
        }

        return Column(
          children: [
            _stepDots(),
            Expanded(
              child: switch (checkoutController.step.value) {
                1 => _step1(),
                2 => _step2(),
                _ => _step3(),
              },
            ),
          ],
        );
      }),
    );
  }
}
