import 'package:flutter/material.dart';
import 'package:ventalink_mobile/main.dart';

class RoutingService {
  static Future<void> push(Widget page) async {
    await Navigator.push(
      NavigationService.navigatorKey.currentContext!,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  static Future<void> pushReplacement(Widget page) async {
    await Navigator.pushReplacement(
      NavigationService.navigatorKey.currentContext!,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  static Future<void> pushAndRemoveUntil(Widget page) async {
    await Navigator.pushAndRemoveUntil(
      NavigationService.navigatorKey.currentContext!,
      MaterialPageRoute(builder: (context) => page),
      (route) => false,
    );
  }
}
