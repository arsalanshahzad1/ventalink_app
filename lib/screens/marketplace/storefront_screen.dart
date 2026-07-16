import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ventalink_mobile/controllers/marketplace_controller.dart';
import 'package:ventalink_mobile/models/store_model.dart';
import 'package:ventalink_mobile/screens/checkout/checkout_screen.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/utils/formatters.dart';
import 'package:ventalink_mobile/utils/prompts.dart';
import 'package:ventalink_mobile/utils/routing_service.dart';
import 'package:ventalink_mobile/widgets/gradient_button.dart';

class StorefrontScreen extends StatefulWidget {
  final String slug;

  const StorefrontScreen({super.key, required this.slug});

  @override
  State<StorefrontScreen> createState() => _StorefrontScreenState();
}

class _StorefrontScreenState extends State<StorefrontScreen> {
  final marketplaceController = Get.find<MarketplaceController>();

  /// Ephemeral cart for this storefront visit, mirrors web's Storefront.tsx cart state.
  final RxMap<String, int> cart = <String, int>{}.obs;

  @override
  void initState() {
    super.initState();
    marketplaceController.loadStore(widget.slug);
  }

  Future<void> _contactSeller(String whatsappNumber) async {
    final digitsOnly = whatsappNumber.split("").where((char) => "0123456789".contains(char)).join();
    if (digitsOnly.isEmpty) {
      Prompts.showSnackBar("This store hasn't added a WhatsApp number yet");
      return;
    }
    final uri = Uri.parse("https://wa.me/$digitsOnly");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      cart.remove(productId);
    } else {
      cart[productId] = quantity.clamp(1, 99);
    }
  }

  void _goToCheckout(PublicStore store, {String? singleProductId}) {
    if (store.openStatus?.isOpenNow == false) return;

    final items = singleProductId != null ? {singleProductId: 1} : Map<String, int>.from(cart);
    if (items.isEmpty) return;

    RoutingService.push(CheckoutScreen(slug: widget.slug, initialCart: items));
  }

  void _showProduct(PublicProduct product, PublicStore store) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(resolveImageUrl(product.imageUrl), height: 160, width: double.infinity, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),
            Text(product.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(formatMoney(product.priceMinor, product.currency), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
            if (product.description != null && product.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(product.description!, style: const TextStyle(fontSize: 13, color: AppColors.textGrey, height: 1.5)),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _goToCheckout(store, singleProductId: product.id);
                    },
                    icon: const Icon(Icons.credit_card_outlined),
                    label: Text(store.openStatus?.isOpenNow == false ? "Store closed" : "Pay now"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
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
        ),
      ),
    );
  }

  Widget _quantityStepper(PublicProduct product, bool isStoreOpen) {
    return Obx(() {
      final qty = cart[product.id] ?? 0;

      if (qty == 0) {
        return SizedBox(
          height: 34,
          child: OutlinedButton.icon(
            onPressed: isStoreOpen ? () => _updateQuantity(product.id, 1) : null,
            icon: const Icon(Icons.add_shopping_cart, size: 14),
            label: const Text("Add", style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        );
      }

      return Container(
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
              iconSize: 16,
              onPressed: () => _updateQuantity(product.id, qty - 1),
              icon: const Icon(Icons.remove, color: AppColors.primary),
            ),
            SizedBox(width: 20, child: Text("$qty", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
              iconSize: 16,
              onPressed: qty >= 99 ? null : () => _updateQuantity(product.id, qty + 1),
              icon: const Icon(Icons.add, color: AppColors.primary),
            ),
          ],
        ),
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
      ),
      body: Obx(() {
        if (marketplaceController.isLoadingStore.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (marketplaceController.storeLoadFailed.value || marketplaceController.currentStore.value == null) {
          return const Center(child: Text("Could not load this store.", style: TextStyle(color: AppColors.textGrey)));
        }

        final store = marketplaceController.currentStore.value!;
        final isStoreOpen = store.openStatus?.isOpenNow ?? true;

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () => marketplaceController.loadStore(widget.slug),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                children: [
                  Row(
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
                            Text(store.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                            if (store.tagline.isNotEmpty) Text(store.tagline, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (store.openStatus != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isStoreOpen ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isStoreOpen ? "Open now · ${store.openStatus!.todayHours}" : "Closed · ${store.openStatus!.todayHours}",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isStoreOpen ? const Color(0xFF15803D) : const Color(0xFFB91C1C)),
                      ),
                    ),
                  ],
                  if (store.walletSettings?.acceptsWalletPayments == true) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.account_balance_wallet_outlined, size: 14, color: AppColors.primary),
                          SizedBox(width: 6),
                          Text("Wallet accepted", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Text("Products", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 12),
                  if (marketplaceController.storeProducts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text("This store hasn't listed any products yet.", style: TextStyle(color: AppColors.textGrey))),
                    )
                  else
                    ...marketplaceController.storeProducts.map(
                      (product) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => _showProduct(product, store),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                                    ? Image.network(resolveImageUrl(product.imageUrl), height: 56, width: 56, fit: BoxFit.cover)
                                    : Container(height: 56, width: 56, color: AppColors.background, child: const Icon(Icons.image_outlined, color: AppColors.textGrey)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _showProduct(product, store),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                    const SizedBox(height: 2),
                                    Text(formatMoney(product.priceMinor, product.currency), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primary)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _quantityStepper(product, isStoreOpen),
                            IconButton(
                              onPressed: () => marketplaceController.toggleFavourite(product),
                              icon: Icon(
                                product.isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: product.isFavorite ? AppColors.primary : AppColors.textGrey,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Obx(() {
              final cartCount = cart.values.fold(0, (sum, qty) => sum + qty);
              if (cartCount == 0) return const SizedBox.shrink();

              final cartTotal = marketplaceController.storeProducts
                  .where((product) => (cart[product.id] ?? 0) > 0)
                  .fold(0, (sum, product) => sum + product.priceMinor * (cart[product.id] ?? 0));
              final currency = marketplaceController.storeProducts.isNotEmpty ? marketplaceController.storeProducts.first.currency : "MXN";

              return Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, -4))],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("$cartCount ${cartCount == 1 ? "item" : "items"}", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textGrey)),
                            Text(formatMoney(cartTotal, currency), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
                          ],
                        ),
                      ),
                      GradientButton.icon(
                        icon: Icons.credit_card_outlined,
                        label: "Review order",
                        onPressed: isStoreOpen ? () => _goToCheckout(store) : null,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}
