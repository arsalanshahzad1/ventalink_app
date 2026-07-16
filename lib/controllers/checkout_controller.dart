import 'dart:developer';

import 'package:get/get.dart';
import 'package:ventalink_mobile/controllers/wallet_controller.dart';
import 'package:ventalink_mobile/models/checkout_model.dart';
import 'package:ventalink_mobile/models/store_model.dart';
import 'package:ventalink_mobile/models/user_model.dart';
import 'package:ventalink_mobile/network/api_endpoints.dart';
import 'package:ventalink_mobile/network/api_service.dart';
import 'package:ventalink_mobile/network/conekta_service.dart';
import 'package:ventalink_mobile/utils/common_utils.dart';

class CheckoutController extends GetxController {
  final String slug;

  CheckoutController({required this.slug, Map<String, int>? initialCart}) {
    if (initialCart != null && initialCart.isNotEmpty) {
      cart.addAll(initialCart);
    }
  }

  static const List<String> hybridMethodIds = ["hybrid_card", "hybrid_spei", "hybrid_conekta"];
  static const Map<String, String> hybridExternalMethod = {
    "hybrid_card": "card",
    "hybrid_spei": "spei",
    "hybrid_conekta": "conekta_card",
  };
  static const Map<String, String> hybridLabels = {
    "hybrid_card": "Wallet + card",
    "hybrid_spei": "Wallet + SPEI",
    "hybrid_conekta": "Wallet + Conekta",
  };

  final RxMap<String, int> cart = <String, int>{}.obs;

  final Rx<PublicStore?> store = Rx<PublicStore?>(null);
  final RxList<PublicProduct> storeProducts = <PublicProduct>[].obs;
  final RxBool isLoadingStore = false.obs;
  final RxBool storeLoadFailed = false.obs;

  final RxInt step = 1.obs;
  final RxString method = "card".obs;
  final RxString walletAmountText = "".obs;
  final RxString notesText = "".obs;
  final RxString checkoutError = "".obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isTokenizing = false.obs;
  final RxBool hasAgreedCardTerms = false.obs;

  final Rx<User?> currentUser = Rx<User?>(null);
  final Rx<CreatePublicOrderResult?> orderResult = Rx<CreatePublicOrderResult?>(null);

  Future<void> init() async {
    final session = await CommonUtils().getSession();
    currentUser.value = session?.user;
    await Get.find<WalletController>().loadWallet();
    await loadStore();
  }

  Future<void> loadStore() async {
    isLoadingStore.value = true;
    storeLoadFailed.value = false;

    try {
      final response = await Api().apiCall(ApiEndpoints.storeBySlug(slug), null, null, RequestType.GET);

      response?.maybeWhen(
        success: (data) {
          final result = StoreDetailResponse.fromJson(data);
          store.value = result.store;
          storeProducts.value = result.products;
          _ensureValidMethod();
        },
        error: (message, statusCode) {
          storeLoadFailed.value = true;
          log("Error Returned with statusCode $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Loading store for checkout failed: $e");
      storeLoadFailed.value = true;
    }

    isLoadingStore.value = false;
  }

  void updateQuantity(String productId, int quantity) {
    checkoutError.value = "";
    if (quantity <= 0) {
      cart.remove(productId);
    } else {
      cart[productId] = quantity.clamp(1, 99);
    }
  }

  List<PublicProduct> get cartItems => storeProducts.where((product) => (cart[product.id] ?? 0) > 0).toList();

  int get totalMinor => cartItems.fold(0, (sum, product) => sum + product.priceMinor * (cart[product.id] ?? 0));

  String get currency => cartItems.isNotEmpty ? cartItems.first.currency : (storeProducts.isNotEmpty ? storeProducts.first.currency : "MXN");

  bool get walletEnabled => store.value?.walletSettings?.acceptsWalletPayments ?? false;

  bool get hybridEnabled => walletEnabled && (store.value?.walletSettings?.acceptsHybridPayments ?? false);

  bool get isStoreOpen => store.value?.openStatus?.isOpenNow ?? true;

  bool isHybridMethod(String value) => hybridMethodIds.contains(value);

  List<String> get visibleMethodIds => [
    "card",
    "bank",
    if (walletEnabled) "wallet",
    if (hybridEnabled) ...hybridMethodIds,
  ];

  void _ensureValidMethod() {
    if (!visibleMethodIds.contains(method.value)) {
      method.value = "card";
    }
  }

  int get walletBalanceMinor => Get.find<WalletController>().wallet.value?.balanceMinor ?? 0;

  int get walletAmountMinor {
    if (method.value == "wallet") return totalMinor;
    if (isHybridMethod(method.value)) {
      final entered = ((double.tryParse(walletAmountText.value) ?? 0) * 100).round();
      if (entered <= 0) return 0;
      return entered > totalMinor ? totalMinor : entered;
    }
    return 0;
  }

  bool get walletAmountInvalid =>
      isHybridMethod(method.value) && (walletAmountMinor <= 0 || walletAmountMinor > walletBalanceMinor);

  bool get needsCardToken => method.value == "card" || method.value == "hybrid_card" || method.value == "hybrid_conekta";

  bool get usesSpei => method.value == "bank" || method.value == "hybrid_spei";

  String get apiPaymentMethod => isHybridMethod(method.value) ? "hybrid" : method.value;

  String? get externalPaymentMethod => hybridExternalMethod[method.value];

  /// Tokenizes a card natively against Conekta, then submits the order with
  /// that token — the in-app equivalent of web's CardForm.tsx -> submitOrder flow.
  Future<bool> tokenizeAndSubmitCard({
    required String number,
    required String name,
    required String expMonth,
    required String expYear,
    required String cvc,
  }) async {
    checkoutError.value = "";
    isTokenizing.value = true;

    String tokenId;
    try {
      tokenId = await ConektaService.tokenizeCard(number: number, name: name, expMonth: expMonth, expYear: expYear, cvc: cvc);
    } catch (e) {
      isTokenizing.value = false;
      checkoutError.value = e.toString().replaceFirst("Exception: ", "");
      return false;
    }

    isTokenizing.value = false;
    return submitOrder(tokenId: tokenId);
  }

  /// Submits the order. `tokenId` is required for card-based methods and
  /// omitted for wallet-only / SPEI-only / wallet+SPEI, which need no token.
  Future<bool> submitOrder({String? tokenId}) async {
    checkoutError.value = "";

    if (store.value == null || cartItems.isEmpty) {
      checkoutError.value = "Select at least one product before continuing.";
      return false;
    }
    if (!isStoreOpen) {
      checkoutError.value = "Store is closed now. Today's hours: ${store.value?.openStatus?.todayHours ?? "Closed"}";
      return false;
    }
    if (walletAmountInvalid) {
      checkoutError.value = "Enter a valid wallet amount before continuing.";
      return false;
    }

    isSubmitting.value = true;
    var succeeded = false;

    final body = {
      "slug": slug,
      "channel": "web",
      "isUserAgreed": true,
      "paymentMethod": apiPaymentMethod,
      if (externalPaymentMethod != null) "externalPaymentMethod": externalPaymentMethod,
      "walletAmountMinor": walletAmountMinor,
      if (tokenId != null) "tokenId": tokenId,
      "customer": {
        "name": currentUser.value?.fullName ?? "",
        "phone": currentUser.value?.phone ?? "",
        "email": currentUser.value?.email ?? "",
        "notes": notesText.value,
      },
      "items": cartItems.map((product) => {"productId": product.id, "qty": cart[product.id]}).toList(),
    };

    try {
      final response = await Api().apiCall(ApiEndpoints.publicOrders, null, body, RequestType.POST);

      response?.maybeWhen(
        success: (data) {
          orderResult.value = CreatePublicOrderResult.fromJson(data);
          step.value = 3;
          succeeded = true;
          Get.find<WalletController>().loadWallet();
          Get.find<WalletController>().loadLedger();
        },
        error: (message, statusCode) {
          checkoutError.value = message;
          log("Checkout error $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Checkout submit failed: $e");
      checkoutError.value = "Could not process payment.";
    }

    isSubmitting.value = false;
    return succeeded;
  }
}
