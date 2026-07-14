import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/marketplace_controller.dart';
import 'package:ventalink_mobile/screens/marketplace/storefront_screen.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/utils/formatters.dart';
import 'package:ventalink_mobile/utils/routing_service.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final marketplaceController = Get.find<MarketplaceController>();
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    marketplaceController.loadMarketplace();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        forceMaterialTransparency: true,
        elevation: 0,
        title: const Text("Marketplace", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: TextField(
              controller: searchController,
              onSubmitted: marketplaceController.search,
              decoration: InputDecoration(
                hintText: "Search stores or products",
                hintStyle: const TextStyle(color: AppColors.textGrey),
                prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (marketplaceController.isLoadingMarketplace.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (marketplaceController.stores.isEmpty && marketplaceController.products.isEmpty) {
                return const Center(child: Text("No stores or products found.", style: TextStyle(color: AppColors.textGrey)));
              }

              return RefreshIndicator(
                onRefresh: marketplaceController.loadMarketplace,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    if (marketplaceController.stores.isNotEmpty) ...[
                      const Text("Stores", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 130,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: marketplaceController.stores.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final store = marketplaceController.stores[index];
                            return GestureDetector(
                              onTap: () => RoutingService.push(StorefrontScreen(slug: store.slug)),
                              child: Container(
                                width: 140,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                      backgroundImage: store.logoUrl.isNotEmpty ? NetworkImage(resolveImageUrl(store.logoUrl)) : null,
                                      child: store.logoUrl.isEmpty
                                          ? Text(store.name.isNotEmpty ? store.name[0].toUpperCase() : "?", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700))
                                          : null,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(store.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                    const SizedBox(height: 2),
                                    Text("${store.productCount} products", style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (marketplaceController.products.isNotEmpty) ...[
                      const Text("Products", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: marketplaceController.products.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                        itemBuilder: (context, index) {
                          final product = marketplaceController.products[index];
                          return GestureDetector(
                            onTap: () => RoutingService.push(StorefrontScreen(slug: product.store.slug)),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                      child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                                          ? Image.network(resolveImageUrl(product.imageUrl), fit: BoxFit.cover, width: double.infinity)
                                          : Container(color: AppColors.background, child: const Icon(Icons.image_outlined, color: AppColors.textGrey)),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                                        const SizedBox(height: 2),
                                        Text(product.store.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppColors.textGrey)),
                                        const SizedBox(height: 4),
                                        Text(formatMoney(product.priceMinor, product.currency), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primary)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
