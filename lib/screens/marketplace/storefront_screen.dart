import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ventalink_mobile/controllers/marketplace_controller.dart';
import 'package:ventalink_mobile/models/store_model.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/utils/formatters.dart';
import 'package:ventalink_mobile/utils/prompts.dart';

class StorefrontScreen extends StatefulWidget {
  final String slug;

  const StorefrontScreen({super.key, required this.slug});

  @override
  State<StorefrontScreen> createState() => _StorefrontScreenState();
}

class _StorefrontScreenState extends State<StorefrontScreen> {
  final marketplaceController = Get.find<MarketplaceController>();

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

        return RefreshIndicator(
          onRefresh: () => marketplaceController.loadStore(widget.slug),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    color: store.openStatus!.isOpenNow ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    store.openStatus!.isOpenNow ? "Open now · ${store.openStatus!.todayHours}" : "Closed · ${store.openStatus!.todayHours}",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: store.openStatus!.isOpenNow ? const Color(0xFF15803D) : const Color(0xFFB91C1C)),
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
                  (product) => GestureDetector(
                    onTap: () => _showProduct(product, store),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                                ? Image.network(resolveImageUrl(product.imageUrl), height: 56, width: 56, fit: BoxFit.cover)
                                : Container(height: 56, width: 56, color: AppColors.background, child: const Icon(Icons.image_outlined, color: AppColors.textGrey)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                const SizedBox(height: 2),
                                Text(formatMoney(product.priceMinor, product.currency), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primary)),
                              ],
                            ),
                          ),
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
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }
}
