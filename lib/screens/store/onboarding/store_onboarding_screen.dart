import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/store/store_products_controller.dart';
import 'package:ventalink_mobile/controllers/store/store_profile_controller.dart';
import 'package:ventalink_mobile/screens/store/store_shell.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/utils/image_picker_helper.dart';
import 'package:ventalink_mobile/utils/prompts.dart';
import 'package:ventalink_mobile/utils/routing_service.dart';
import 'package:ventalink_mobile/widgets/custom_button.dart';
import 'package:ventalink_mobile/widgets/remote_or_data_image.dart';

class StoreOnboardingScreen extends StatefulWidget {
  const StoreOnboardingScreen({super.key});

  @override
  State<StoreOnboardingScreen> createState() => _StoreOnboardingScreenState();
}

class _StoreOnboardingScreenState extends State<StoreOnboardingScreen> {
  final storeProfileController = Get.find<StoreProfileController>();
  final storeProductsController = Get.find<StoreProductsController>();

  int _step = 0;
  bool _submitting = false;

  final nameController = TextEditingController();
  final whatsappController = TextEditingController();
  String _dialCode = "+52";
  String? _logoUrl;

  final productNameController = TextEditingController();
  final productPriceController = TextEditingController();
  String? _productImageUrl;

  String get _slugPreview {
    final slug = nameController.text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9]+"), "-")
        .replaceAll(RegExp(r"^-+|-+$"), "");
    return slug.isEmpty ? "your-store" : slug;
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textGrey),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.4)),
    );
  }

  Future<void> _pickLogo() async {
    final encoded = await pickAndEncodeImage();
    if (encoded != null && mounted) setState(() => _logoUrl = encoded);
  }

  Future<void> _pickProductImage() async {
    final encoded = await pickAndEncodeImage();
    if (encoded != null && mounted) setState(() => _productImageUrl = encoded);
  }

  Future<void> _submitStore() async {
    final name = nameController.text.trim();
    final whatsapp = whatsappController.text.trim();

    if (name.length < 2) {
      Prompts.showSnackBar("Enter your store name");
      return;
    }
    if (whatsapp.length < 5) {
      Prompts.showSnackBar("Enter your WhatsApp number");
      return;
    }

    setState(() => _submitting = true);

    final result = await storeProfileController.createStore({
      "name": name,
      "slug": _slugPreview,
      "whatsappNumber": "$_dialCode$whatsapp".replaceAll(RegExp(r"[^0-9+]"), ""),
      if (_logoUrl != null) "logoUrl": _logoUrl,
      "tagline": "",
      "currency": "MXN",
    });

    if (!result.success && !(result.message ?? "").toLowerCase().contains("already exists")) {
      if (mounted) setState(() => _submitting = false);
      Prompts.showSnackBar(result.message ?? "Could not create your store");
      return;
    }

    final productName = productNameController.text.trim();
    final productPrice = double.tryParse(productPriceController.text.trim());

    if (productName.isNotEmpty && productPrice != null && productPrice > 0) {
      await storeProductsController.createProduct({
        "name": productName,
        "priceMinor": (productPrice * 100).round(),
        if (_productImageUrl != null) "imageUrl": _productImageUrl,
      });
    }

    if (!mounted) return;
    setState(() {
      _submitting = false;
      _step = 2;
    });
  }

  Widget _buildStepName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Set up your store", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(height: 6),
        const Text("Tell customers who you are.", style: TextStyle(fontSize: 14, color: AppColors.textGrey)),
        const SizedBox(height: 24),
        Center(
          child: GestureDetector(
            onTap: _pickLogo,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _logoUrl != null
                    ? RemoteOrDataImage(url: _logoUrl, width: 96, height: 96)
                    : const Center(child: Icon(Icons.add_a_photo_outlined, color: AppColors.textGrey)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(child: TextButton(onPressed: _pickLogo, child: const Text("Add store logo"))),
        const SizedBox(height: 16),
        TextField(controller: nameController, decoration: _fieldDecoration("Store name"), onChanged: (_) => setState(() {})),
        const SizedBox(height: 8),
        Text("ventalink.app/$_slugPreview", style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
        const SizedBox(height: 16),
        Row(
          children: [
            CountryCodePicker(
              onChanged: (code) => setState(() => _dialCode = code.dialCode ?? "+52"),
              initialSelection: "MX",
              favorite: const ["MX", "US"],
              padding: EdgeInsets.zero,
            ),
            Expanded(
              child: TextField(
                controller: whatsappController,
                keyboardType: TextInputType.phone,
                decoration: _fieldDecoration("WhatsApp number"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        CustomButton(label: "Continue", isLoading: false, onPressed: () => setState(() => _step = 1)),
      ],
    );
  }

  Widget _buildStepProduct() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Add your first product", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(height: 6),
        const Text("Optional — you can always add products later.", style: TextStyle(fontSize: 14, color: AppColors.textGrey)),
        const SizedBox(height: 24),
        Center(
          child: GestureDetector(
            onTap: _pickProductImage,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _productImageUrl != null
                    ? RemoteOrDataImage(url: _productImageUrl, width: 96, height: 96)
                    : const Center(child: Icon(Icons.add_a_photo_outlined, color: AppColors.textGrey)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(controller: productNameController, decoration: _fieldDecoration("Product name")),
        const SizedBox(height: 12),
        TextField(
          controller: productPriceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _fieldDecoration("Price, e.g. 99.00"),
        ),
        const SizedBox(height: 24),
        CustomButton(label: "Finish Setup", isLoading: _submitting, onPressed: _submitStore),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: _submitting ? null : () async {
              productNameController.clear();
              productPriceController.clear();
              _productImageUrl = null;
              await _submitStore();
            },
            child: const Text("Skip for now"),
          ),
        ),
      ],
    );
  }

  Widget _buildStepDone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Container(
          height: 88,
          width: 88,
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
          child: const Icon(Icons.check, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 24),
        const Text("You're all set!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(height: 8),
        const Text("Your store is live. Let's go to your dashboard.", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.textGrey)),
        const SizedBox(height: 32),
        CustomButton(label: "Go to Dashboard", onPressed: () => RoutingService.pushAndRemoveUntil(const StoreShellScreen())),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = [_buildStepName(), _buildStepProduct(), _buildStepDone()];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: steps[_step],
        ),
      ),
    );
  }
}
