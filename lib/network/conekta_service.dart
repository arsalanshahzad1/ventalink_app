import 'dart:convert';

import 'package:dio/dio.dart';

/// Tokenizes cards directly against Conekta's REST API using the store's
/// public key, matching what web's CardForm.tsx does through Conekta's JS
/// SDK (which is itself a thin wrapper around this same tokens endpoint).
/// Public keys are safe to embed client-side by design.
class ConektaService {
  static const String _publicKey = "key_Al5UfS20fl7IMo4l3gxAhYJ";
  static const String _tokensUrl = "https://api.conekta.io/tokens";

  static Future<String> tokenizeCard({
    required String number,
    required String name,
    required String expMonth,
    required String expYear,
    required String cvc,
  }) async {
    final dio = Dio();
    final credentials = base64Encode(utf8.encode("$_publicKey:"));

    try {
      final response = await dio.post(
        _tokensUrl,
        options: Options(
          headers: {
            "Authorization": "Basic $credentials",
            "Accept": "application/vnd.conekta-v2.0.0+json",
            "Content-Type": "application/json",
          },
          validateStatus: (status) => status != null && status < 500,
        ),
        data: {
          "card": {
            "number": number,
            "name": name,
            "exp_month": expMonth,
            "exp_year": expYear,
            "cvc": cvc,
          },
        },
      );

      final data = response.data;
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        final tokenId = data is Map ? data["id"] as String? : null;
        if (tokenId == null || tokenId.isEmpty) {
          throw Exception("Could not tokenize card.");
        }
        return tokenId;
      }

      final message = data is Map
          ? (data["details"] is List && (data["details"] as List).isNotEmpty
              ? (data["details"] as List).first["message"]
              : data["message"])
          : null;
      throw Exception(message?.toString() ?? "Could not tokenize card.");
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map
          ? (data["details"] is List && (data["details"] as List).isNotEmpty
              ? (data["details"] as List).first["message"]
              : data["message"])
          : null;
      throw Exception(message?.toString() ?? "Could not reach the payment service.");
    }
  }
}
