import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/store/store_profile_controller.dart';
import 'package:ventalink_mobile/models/store/store_profile_model.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/utils/image_picker_helper.dart';
import 'package:ventalink_mobile/utils/prompts.dart';
import 'package:ventalink_mobile/widgets/custom_button.dart';
import 'package:ventalink_mobile/widgets/remote_or_data_image.dart';

const _weekdayLabels = {
  "mon": "Monday",
  "tue": "Tuesday",
  "wed": "Wednesday",
  "thu": "Thursday",
  "fri": "Friday",
  "sat": "Saturday",
  "sun": "Sunday",
};

class StoreSettingsScreen extends StatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  State<StoreSettingsScreen> createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends State<StoreSettingsScreen> {
  final storeProfileController = Get.find<StoreProfileController>();

  final nameController = TextEditingController();
  final whatsappController = TextEditingController();
  final taglineController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();
  final latController = TextEditingController();
  final lngController = TextEditingController();

  String? _pendingLogo;
  bool _prefilled = false;
  bool _hoursEnabled = false;
  bool _acceptsWallet = false;
  bool _acceptsHybrid = false;
  bool _rewardEnabled = false;
  List<StoreDaySchedule> _weekly = [];

  void _prefill(StoreProfile store) {
    if (_prefilled) return;
    _prefilled = true;
    nameController.text = store.name;
    whatsappController.text = store.whatsappNumber;
    taglineController.text = store.tagline;
    addressController.text = store.address;
    cityController.text = store.city;
    stateController.text = store.state;
    countryController.text = store.country;
    latController.text = store.location.lat?.toString() ?? "";
    lngController.text = store.location.lng?.toString() ?? "";
    _hoursEnabled = store.operatingHours.enabled;
    _weekly = store.operatingHours.weeklySchedule.map((d) => d).toList();
    _acceptsWallet = store.walletSettings.acceptsWalletPayments;
    _acceptsHybrid = store.walletSettings.acceptsHybridPayments;
    _rewardEnabled = store.walletSettings.rewardParticipationEnabled;
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

  Future<void> _pickLogo() async {
    final encoded = await pickAndEncodeImage();
    if (encoded != null && mounted) setState(() => _pendingLogo = encoded);
  }

  Future<void> _saveProfile() async {
    if (nameController.text.trim().isEmpty) {
      Prompts.showSnackBar("Store name is required");
      return;
    }

    final success = await storeProfileController.updateStore({
      "name": nameController.text.trim(),
      "whatsappNumber": whatsappController.text.trim(),
      "tagline": taglineController.text.trim(),
      if (_pendingLogo != null) "logoUrl": _pendingLogo,
    });

    if (success) {
      Prompts.showSnackBar("Store profile updated");
      if (mounted) setState(() => _pendingLogo = null);
    }
  }

  Future<void> _saveHours() async {
    final success = await storeProfileController.updateStore({
      "operatingHours": {
        "enabled": _hoursEnabled,
        "weeklySchedule": _weekly.map((d) => d.toJson()).toList(),
      },
    });
    if (success) Prompts.showSnackBar("Operating hours updated");
  }

  Future<void> _saveLocation() async {
    final lat = double.tryParse(latController.text.trim());
    final lng = double.tryParse(lngController.text.trim());

    final success = await storeProfileController.updateStore({
      "address": addressController.text.trim(),
      "city": cityController.text.trim(),
      "state": stateController.text.trim(),
      if (countryController.text.trim().isNotEmpty) "country": countryController.text.trim(),
      if (lat != null && lng != null) "location": {"lat": lat, "lng": lng},
    });
    if (success) Prompts.showSnackBar("Location updated");
  }

  Future<void> _saveWalletSettings() async {
    final success = await storeProfileController.updateStore({
      "walletSettings": {
        "acceptsWalletPayments": _acceptsWallet,
        "acceptsHybridPayments": _acceptsHybrid,
        "rewardParticipationEnabled": _rewardEnabled,
      },
    });
    if (success) Prompts.showSnackBar("Payment settings updated");
  }

  Future<void> _pickTime(int index, bool isOpenTime) async {
    final day = _weekly[index];
    final current = isOpenTime ? day.openTime : day.closeTime;
    final parts = current.split(":");
    final initial = TimeOfDay(hour: int.tryParse(parts[0]) ?? 9, minute: int.tryParse(parts.length > 1 ? parts[1] : "0") ?? 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null || !mounted) return;

    final formatted = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
    setState(() {
      if (isOpenTime) {
        day.openTime = formatted;
      } else {
        day.closeTime = formatted;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text("Store Settings", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: Obx(() {
        final store = storeProfileController.store.value;
        if (store == null) return const Center(child: CircularProgressIndicator());
        _prefill(store);

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _sectionCard(
              title: "Store Profile",
              icon: Icons.storefront_outlined,
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _pickLogo,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: _pendingLogo != null
                                ? RemoteOrDataImage(url: _pendingLogo, width: 64, height: 64)
                                : RemoteOrDataImage(
                                    url: store.logoUrl,
                                    width: 64,
                                    height: 64,
                                    placeholderBuilder: (_) => const Icon(Icons.storefront_outlined, color: AppColors.textGrey),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextButton(onPressed: _pickLogo, child: const Text("Change logo")),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: nameController, decoration: _fieldDecoration("Store name")),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                    child: Text("ventalink.app/${store.slug}", style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: whatsappController, keyboardType: TextInputType.phone, decoration: _fieldDecoration("WhatsApp number")),
                  const SizedBox(height: 12),
                  TextField(controller: taglineController, decoration: _fieldDecoration("Tagline (optional)")),
                  const SizedBox(height: 14),
                  CustomButton(label: "Save Profile", isLoading: storeProfileController.isSaving.value, onPressed: _saveProfile, height: 46),
                ],
              ),
            ),
            _sectionCard(
              title: "Operating Hours",
              icon: Icons.schedule_outlined,
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Show operating hours", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    value: _hoursEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (value) => setState(() => _hoursEnabled = value),
                  ),
                  if (_hoursEnabled)
                    ..._weekly.asMap().entries.map((entry) {
                      final index = entry.key;
                      final day = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            SizedBox(width: 90, child: Text(_weekdayLabels[day.day] ?? day.day, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                            Switch(
                              value: day.isOpen,
                              activeColor: AppColors.primary,
                              onChanged: (value) => setState(() => day.isOpen = value),
                            ),
                            if (day.isOpen) ...[
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _pickTime(index, true),
                                  child: Text(day.openTime, style: const TextStyle(fontSize: 12)),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _pickTime(index, false),
                                  child: Text(day.closeTime, style: const TextStyle(fontSize: 12)),
                                ),
                              ),
                            ] else
                              const Expanded(child: Text("Closed", style: TextStyle(fontSize: 12, color: AppColors.textGrey))),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 8),
                  CustomButton(label: "Save Hours", isLoading: storeProfileController.isSaving.value, onPressed: _saveHours, height: 46),
                ],
              ),
            ),
            _sectionCard(
              title: "Location",
              icon: Icons.place_outlined,
              child: Column(
                children: [
                  TextField(controller: addressController, decoration: _fieldDecoration("Street address")),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: cityController, decoration: _fieldDecoration("City"))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: stateController, decoration: _fieldDecoration("State"))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: countryController, decoration: _fieldDecoration("Country code (e.g. MX)"))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: latController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          decoration: _fieldDecoration("Latitude (optional)"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: lngController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          decoration: _fieldDecoration("Longitude (optional)"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  CustomButton(label: "Save Location", isLoading: storeProfileController.isSaving.value, onPressed: _saveLocation, height: 46),
                ],
              ),
            ),
            _sectionCard(
              title: "Wallet & Payments",
              icon: Icons.account_balance_wallet_outlined,
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Accept wallet payments", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    value: _acceptsWallet,
                    activeColor: AppColors.primary,
                    onChanged: (value) => setState(() {
                      _acceptsWallet = value;
                      if (!value) _acceptsHybrid = false;
                    }),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Accept hybrid payments", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    value: _acceptsHybrid,
                    activeColor: AppColors.primary,
                    onChanged: _acceptsWallet ? (value) => setState(() => _acceptsHybrid = value) : null,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Reward participation", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    value: _rewardEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (value) => setState(() => _rewardEnabled = value),
                  ),
                  const SizedBox(height: 6),
                  CustomButton(
                    label: "Save Payment Settings",
                    isLoading: storeProfileController.isSaving.value,
                    onPressed: _saveWalletSettings,
                    height: 46,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
