import 'dart:developer';

import 'package:get/get.dart';
import 'package:ventalink_mobile/models/store_model.dart';
import 'package:ventalink_mobile/network/api_endpoints.dart';
import 'package:ventalink_mobile/network/api_service.dart';
import 'package:ventalink_mobile/utils/prompts.dart';

class MarketplaceController extends GetxController {
  final RxList<MarketplaceProduct> products = <MarketplaceProduct>[].obs;
  final RxList<PublicStore> stores = <PublicStore>[].obs;
  final RxBool isLoadingMarketplace = false.obs;
  final RxString searchQuery = "".obs;

  final Rx<PublicStore?> currentStore = Rx<PublicStore?>(null);
  final RxList<PublicProduct> storeProducts = <PublicProduct>[].obs;
  final RxBool isLoadingStore = false.obs;
  final RxBool storeLoadFailed = false.obs;

  Future<void> loadMarketplace() async {
    isLoadingMarketplace.value = true;

    final query = <String, dynamic>{"limit": 30};
    if (searchQuery.value.trim().isNotEmpty) {
      query["q"] = searchQuery.value.trim();
    }

    try {
      final response = await Api().apiCall(ApiEndpoints.marketplace, query, null, RequestType.GET);

      response?.maybeWhen(
        success: (data) {
          final result = MarketplaceResponse.fromJson(data);
          products.value = result.products;
          stores.value = result.stores;
        },
        error: (message, statusCode) {
          log("Error Returned with statusCode $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Loading marketplace failed: $e");
    }

    isLoadingMarketplace.value = false;
  }

  void search(String query) {
    searchQuery.value = query;
    loadMarketplace();
  }

  Future<void> loadStore(String slug) async {
    isLoadingStore.value = true;
    storeLoadFailed.value = false;
    currentStore.value = null;
    storeProducts.clear();

    try {
      final response = await Api().apiCall(ApiEndpoints.storeBySlug(slug), null, null, RequestType.GET);

      response?.maybeWhen(
        success: (data) {
          final result = StoreDetailResponse.fromJson(data);
          currentStore.value = result.store;
          storeProducts.value = result.products;
        },
        error: (message, statusCode) {
          storeLoadFailed.value = true;
          log("Error Returned with statusCode $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Loading store failed: $e");
      storeLoadFailed.value = true;
    }

    isLoadingStore.value = false;
  }

  Future<void> toggleFavourite(PublicProduct product) async {
    final wasFavorite = product.isFavorite;
    product.isFavorite = !wasFavorite;
    storeProducts.refresh();
    products.refresh();

    try {
      await Api().apiCall(ApiEndpoints.toggleProductFavourite(product.id), null, {}, wasFavorite ? RequestType.DELETE : RequestType.POST);
    } catch (e) {
      log("Toggling favourite failed: $e");
      product.isFavorite = wasFavorite;
      storeProducts.refresh();
      products.refresh();
      Prompts.showSnackBar("Could not update favourite");
    }
  }
}
