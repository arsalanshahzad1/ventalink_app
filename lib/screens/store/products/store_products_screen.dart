import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/store/store_products_controller.dart';
import 'package:ventalink_mobile/models/store/merchant_product_model.dart';
import 'package:ventalink_mobile/screens/store/products/product_form_sheet.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/utils/formatters.dart';
import 'package:ventalink_mobile/widgets/remote_or_data_image.dart';

class StoreProductsScreen extends StatefulWidget {
  const StoreProductsScreen({super.key});

  @override
  State<StoreProductsScreen> createState() => _StoreProductsScreenState();
}

class _StoreProductsScreenState extends State<StoreProductsScreen> {
  final storeProductsController = Get.find<StoreProductsController>();

  Widget _filterChip(String value, String label) {
    return Obx(() {
      final selected = storeProductsController.statusFilter.value == value;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => storeProductsController.loadProducts(status: value),
          selectedColor: AppColors.primary.withValues(alpha: 0.15),
          labelStyle: TextStyle(color: selected ? AppColors.primary : AppColors.textGrey, fontWeight: FontWeight.w600, fontSize: 12),
          side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
          backgroundColor: AppColors.white,
        ),
      );
    });
  }

  Widget _productTile(MerchantProduct product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: InkWell(
        onTap: () => showProductFormSheet(context, product: product),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: RemoteOrDataImage(
                url: product.imageUrl,
                width: 56,
                height: 56,
                placeholderBuilder: (_) => Container(
                  width: 56,
                  height: 56,
                  color: AppColors.background,
                  child: const Icon(Icons.inventory_2_outlined, color: AppColors.textGrey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(formatMoney(product.priceMinor, product.currency), style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (product.isActive ? const Color(0xFF16A34A) : AppColors.textGrey).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    product.isActive ? "Active" : "Inactive",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: product.isActive ? const Color(0xFF16A34A) : AppColors.textGrey),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                  onPressed: () => _confirmDelete(product),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(MerchantProduct product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete product?", style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('This will remove "${product.name}" from your store.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Delete", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed == true) storeProductsController.deleteProduct(product.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text("Products", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => showProductFormSheet(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: () => storeProductsController.loadProducts(status: storeProductsController.statusFilter.value),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(children: [_filterChip("all", "All"), _filterChip("active", "Active"), _filterChip("inactive", "Inactive")]),
              const SizedBox(height: 16),
              if (storeProductsController.isLoading.value)
                const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: CircularProgressIndicator()))
              else if (storeProductsController.products.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text("No products yet. Tap + to add one.", style: TextStyle(color: AppColors.textGrey))),
                )
              else
                ...storeProductsController.products.map(_productTile),
            ],
          ),
        );
      }),
    );
  }
}
