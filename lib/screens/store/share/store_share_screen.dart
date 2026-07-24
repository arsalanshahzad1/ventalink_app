import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ventalink_mobile/controllers/store/store_profile_controller.dart';
import 'package:ventalink_mobile/network/api_endpoints.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/utils/prompts.dart';

String getPublicStoreUrl(String slug) => "${GlobalEndpoints.publicAppUrl}/$slug";

String getQrCodeUrl(String value, {int size = 320}) =>
    "https://api.qrserver.com/v1/create-qr-code/?size=${size}x$size&data=${Uri.encodeComponent(value)}&color=1A1A2E&bgcolor=FFFFFF";

class StoreShareScreen extends StatelessWidget {
  const StoreShareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storeProfileController = Get.find<StoreProfileController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text("Share your store", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: Obx(() {
        final store = storeProfileController.store.value;
        if (store == null) return const Center(child: CircularProgressIndicator());

        final url = getPublicStoreUrl(store.slug);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(getQrCodeUrl(url, size: 240), width: 240, height: 240),
                    ),
                    const SizedBox(height: 16),
                    Text(url, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: url));
                    Prompts.showSnackBar("Link copied");
                  },
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text("Copy link"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => launchUrl(
                    Uri.parse("https://wa.me/?text=${Uri.encodeComponent("Check out my store: $url")}"),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.chat_outlined, color: Colors.white),
                  label: const Text("Share on WhatsApp", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
