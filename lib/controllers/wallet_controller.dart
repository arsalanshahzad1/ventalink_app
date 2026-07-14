import 'dart:developer';
import 'dart:math' hide log;

import 'package:get/get.dart';
import 'package:ventalink_mobile/models/wallet_model.dart';
import 'package:ventalink_mobile/network/api_endpoints.dart';
import 'package:ventalink_mobile/network/api_service.dart';
import 'package:ventalink_mobile/utils/prompts.dart';

class WalletController extends GetxController {
  final Rx<Wallet?> wallet = Rx<Wallet?>(null);
  final RxList<WalletLedgerEntry> ledgerEntries = <WalletLedgerEntry>[].obs;
  final RxList<WalletTopUpIntent> topUps = <WalletTopUpIntent>[].obs;

  final RxBool isLoadingWallet = false.obs;
  final RxBool isLoadingLedger = false.obs;
  final RxBool isSubmittingTopUp = false.obs;
  final RxBool isSendingGift = false.obs;

  Future<void> loadAll() async {
    await Future.wait([loadWallet(), loadLedger(), loadTopUps()]);
  }

  Future<void> loadWallet() async {
    isLoadingWallet.value = true;
    try {
      final response = await Api().apiCall(ApiEndpoints.myWallet, {"currency": "MXN"}, null, RequestType.GET);
      log("Logging Wallet after api service layer");

      response?.maybeWhen(
        success: (data) {
          wallet.value = Wallet.fromJson(data["wallet"]);
        },
        error: (message, statusCode) {},
        orElse: () {},
      );
    } catch (e) {
      log("Loading wallet failed: $e");
    }
    isLoadingWallet.value = false;
  }

  Future<void> loadLedger() async {
    isLoadingLedger.value = true;
    try {
      final response = await Api().apiCall(ApiEndpoints.myWalletLedger, {"currency": "MXN", "limit": 20}, null, RequestType.GET);

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
      log("Loading ledger failed: $e");
    }
    isLoadingLedger.value = false;
  }

  Future<void> loadTopUps() async {
    try {
      final response = await Api().apiCall(ApiEndpoints.myWalletTopUps, {"currency": "MXN", "limit": 20}, null, RequestType.GET);

      response?.maybeWhen(
        success: (data) {
          log("loadTopUps Success :: ()");
          topUps.value = (data["items"] as List).map((item) => WalletTopUpIntent.fromJson(item)).toList();
        },
        error: (message, statusCode) {
          log("Error Returned with statusCode $message $statusCode");
        },
        orElse: () {},
      );
    } catch (e) {
      log("Loading top-ups failed: $e");
    }
  }

  Future<void> submitTopUp(int amountMinor) async {
    isSubmittingTopUp.value = true;

    final body = {"amountMinor": amountMinor, "provider": "manual", "paymentMethod": "manual"};

    try {
      final response = await Api().apiCall(ApiEndpoints.myWalletTopUps, null, body, RequestType.POST);

      response?.maybeWhen(
        success: (data) {
          Prompts.showSnackBar("Top-up request is pending admin confirmation");
          loadTopUps();
        },
        error: (message, statusCode) => Prompts.showSnackBar(message),
        orElse: () {},
      );
    } catch (e) {
      log("Top-up request failed: $e");
      Prompts.showSnackBar("Could not create top-up");
    }

    isSubmittingTopUp.value = false;
  }

  Future<void> sendGift(String recipientEmail, int amountMinor, String message) async {
    isSendingGift.value = true;

    final body = {
      "recipientEmail": recipientEmail,
      "amountMinor": amountMinor,
      "currency": wallet.value?.currency ?? "MXN",
      "message": message.isEmpty ? null : message,
      "idempotencyKey": "gift-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1 << 32)}",
    };

    try {
      final response = await Api().apiCall(ApiEndpoints.walletGift, null, body, RequestType.POST);

      response?.maybeWhen(
        success: (data) {
          final result = WalletGiftResult.fromJson(data);
          Prompts.showSnackBar("Gift sent to ${result.recipientName}");
          loadWallet();
          loadLedger();
        },
        error: (message, statusCode) {
          log("Error Returned with statusCode $message $statusCode");
          Prompts.showSnackBar(message);
        },
        orElse: () {},
      );
    } catch (error) {
      log("Gift request failed: $error");
      Prompts.showSnackBar("Could not send gift");
    }

    isSendingGift.value = false;
  }
}
