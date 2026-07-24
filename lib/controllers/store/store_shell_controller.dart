import 'package:get/get.dart';

/// Holds the active tab index for [StoreShellScreen] so any descendant
/// (e.g. an action card on Overview) can switch tabs without pushing a
/// second, duplicate instance of a screen that's already kept alive in the
/// shell's IndexedStack.
class StoreShellController extends GetxController {
  final RxInt currentTab = 0.obs;

  void goToTab(int index) => currentTab.value = index;
}
