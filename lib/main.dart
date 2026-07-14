import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:ventalink_mobile/screens/auth/splash_screen.dart';
import 'package:ventalink_mobile/utils/app_bindings.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpClient.enableTimelineLogging = true;
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          initialBinding: AppBindings(),
          title: 'Ventalink Mobile App',
          debugShowCheckedModeBanner: false,
          navigatorKey: NavigationService.navigatorKey,
          useInheritedMediaQuery: true,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, primary: AppColors.primary),
            progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primary),
          ),
          home: const SplashScreen(),
          builder: (context, child) {
            return DismissKeyboard(child: SafeArea(top: false, bottom: true, child: child ?? const SizedBox()));
          },
        );
      },
    );
  }
}

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

class DismissKeyboard extends StatelessWidget {
  const DismissKeyboard({super.key, required this.child});

  final Widget child;

  void _unfocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(behavior: HitTestBehavior.translucent, onTap: _unfocus, child: child);
  }
}
