import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/store/store_products_controller.dart';
import 'package:ventalink_mobile/models/store/merchant_product_model.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/utils/image_picker_helper.dart';
import 'package:ventalink_mobile/utils/prompts.dart';
import 'package:ventalink_mobile/widgets/custom_button.dart';
import 'package:ventalink_mobile/widgets/remote_or_data_image.dart';

Future<void> showProductFormSheet(BuildContext context, {MerchantProduct? product}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ProductFormSheet(product: product),
  );
}

class ProductFormSheet extends StatefulWidget {
  final MerchantProduct? product;

  const ProductFormSheet({super.key, this.product});

  @override
  State<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<ProductFormSheet> {
  final storeProductsController = Get.find<StoreProductsController>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  String? _imageUrl;
  bool _isActive = true;
  bool _walletEligible = false;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    if (product != null) {
      nameController.text = product.name;
      priceController.text = (product.priceMinor / 100).toStringAsFixed(2);
      descriptionController.text = product.description ?? "";
      _imageUrl = product.imageUrl;
      _isActive = product.isActive;
      _walletEligible = product.walletEligible;
    }
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

  Future<void> _pickImage() async {
    final encoded = await pickAndEncodeImage();
    if (encoded != null && mounted) setState(() => _imageUrl = encoded);
  }

  Future<void> _submit() async {
    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text.trim());

    if (name.isEmpty) {
      Prompts.showSnackBar("Enter a product name");
      return;
    }
    if (price == null || price <= 0) {
      Prompts.showSnackBar("Enter a valid price");
      return;
    }

    final body = {
      "name": name,
      "priceMinor": (price * 100).round(),
      "description": descriptionController.text.trim(),
      if (_imageUrl != null) "imageUrl": _imageUrl,
      "isActive": _isActive,
      "walletEligible": _walletEligible,
    };

    final success = widget.product == null
        ? await storeProductsController.createProduct(body)
        : await storeProductsController.updateProduct(widget.product!.id, body);

    if (success && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4))),
              ),
              const SizedBox(height: 16),
              Text(
                isEditing ? "Edit Product" : "Add Product",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _imageUrl != null
                        ? RemoteOrDataImage(url: _imageUrl, width: 96, height: 96)
                        : const Center(child: Icon(Icons.add_a_photo_outlined, color: AppColors.textGrey)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(controller: nameController, decoration: _fieldDecoration("Product name")),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _fieldDecoration("Price, e.g. 99.00"),
              ),
              const SizedBox(height: 12),
              TextField(controller: descriptionController, maxLines: 3, decoration: _fieldDecoration("Description (optional)")),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Active", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                value: _isActive,
                activeColor: AppColors.primary,
                onChanged: (value) => setState(() => _isActive = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Wallet eligible", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                value: _walletEligible,
                activeColor: AppColors.primary,
                onChanged: (value) => setState(() => _walletEligible = value),
              ),
              const SizedBox(height: 16),
              Obx(
                () => CustomButton(
                  label: isEditing ? "Save Changes" : "Add Product",
                  isLoading: storeProductsController.isSaving.value,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
