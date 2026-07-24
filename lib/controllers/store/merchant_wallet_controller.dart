import 'dart:developer';

import 'package:get/get.dart';
import 'package:ventalink_mobile/models/wallet_model.dart';
import 'package:ventalink_mobile/network/api_endpoints.dart';
import 'package:ventalink_mobile/network/api_service.dart';
import 'package:ventalink_mobile/utils/prompts.dart';

class MerchantWalletController extends GetxController {
  final Rx<Wallet?> wallet = Rx<Wallet?>(null);
  final RxList<WalletLedgerEntry> ledgerEntries = <WalletLedgerEntry>[].obs;
  final RxList<WalletTopUpIntent> bulkPurchases = <WalletTopUpIntent>[].obs;

  final RxBool isLoadingWallet = false.obs;
  final RxBool isLoadingLedger = false.obs;
  final RxBool isSubmittingBulkPurchase = false.obs;

  Future<void> loadAll() async {
    await Future.wait([loadWallet(), loadLedger(), loadBulkPurchases()]);
  }

  Future<void> loadWallet() async {
    isLoadingWallet.value = true;
    try {
      final response = await Api().apiCall(ApiEndpoints.merchantWallet, null, null, RequestType.GET);

      response?.maybeWhen(
        success: (data) {
          log("logged wallet data :: $data");
          wallet.value = Wallet.fromJson(data["wallet"]);
        },
        error: (message, statusCode) {
          log("Error Returned with statusCode $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Loading merchant wallet failed: $e");
    }
    isLoadingWallet.value = false;
  }

  Future<void> loadLedger({int limit = 20}) async {
    isLoadingLedger.value = true;
    try {
      final response = await Api().apiCall(ApiEndpoints.merchantWalletLedger, {"limit": limit}, null, RequestType.GET);

      response?.maybeWhen(
        success: (data) {
          ledgerEntries.value = WalletLedgerResponse.fromJson(data).items;
        },
        error: (message, statusCode) {
          log("Error Returned with statusCode $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Loading merchant ledger failed: $e");
    }
    isLoadingLedger.value = false;
  }

  Future<void> loadBulkPurchases({int limit = 20}) async {
    try {
      final response = await Api().apiCall(ApiEndpoints.merchantBulkPurchases, {"limit": limit}, null, RequestType.GET);

      response?.maybeWhen(
        success: (data) {
          bulkPurchases.value = (data["items"] as List? ?? []).map((item) => WalletTopUpIntent.fromJson(item)).toList();
        },
        error: (message, statusCode) {
          log("Error Returned with statusCode $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Loading bulk purchases failed: $e");
    }
  }

  Future<void> submitBulkPurchase(int amountMinor) async {
    isSubmittingBulkPurchase.value = true;

    final body = {"amountMinor": amountMinor, "provider": "manual", "paymentMethod": "manual"};

    try {
      final response = await Api().apiCall(ApiEndpoints.merchantBulkPurchases, null, body, RequestType.POST);

      response?.maybeWhen(
        success: (data) {
          Prompts.showSnackBar("Bulk purchase request is pending admin confirmation");
          loadBulkPurchases();
        },
        error: (message, statusCode) => Prompts.showSnackBar(message),
        orElse: () {},
      );
    } catch (e) {
      log("Bulk purchase request failed: $e");
      Prompts.showSnackBar("Could not create bulk purchase request");
    }

    isSubmittingBulkPurchase.value = false;
  }
}
