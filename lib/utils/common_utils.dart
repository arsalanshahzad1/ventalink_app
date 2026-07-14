import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:ventalink_mobile/models/user_model.dart';

class CommonUtils {
  static const String _accessTokenKey = 'accessToken';
  static const String _userKey = 'user';

  CommonUtils._();
  static CommonUtils? _instance;

  factory CommonUtils() {
    _instance ??= CommonUtils._();
    return _instance!;
  }

  Future<void> saveSession(UserModel userModel) async {
    final prefs = await SharedPreferences.getInstance();
    if (userModel.accessToken != null) {
      await prefs.setString(_accessTokenKey, userModel.accessToken!);
    }
    if (userModel.user != null) {
      await prefs.setString(_userKey, json.encode(userModel.user!.toJson()));
    }
  }

  Future<UserModel?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_accessTokenKey);
    final storedUser = prefs.getString(_userKey);
    if (token == null || storedUser == null) return null;
    // log("Token :: ()-> ${storedUser}");
    return UserModel(accessToken: token, user: User.fromJson(json.decode(storedUser)));
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_userKey);
    log("Keys removed.");
  }
}
