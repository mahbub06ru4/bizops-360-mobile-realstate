import 'package:get/get.dart';

/// The buyer persona's tab set — fixed (no permission variance, unlike
/// `ShellController`/`shellTabsFor` for the staff side: a buyer session
/// carries no roles/permissions to branch on). See `docs/HANDOFF.md` Phase 2.
enum BuyerTabId { browse, saved, myProperties, profile }

class BuyerShellController extends GetxController {
  final RxInt currentIndex = 0.obs;

  static const tabs = BuyerTabId.values;

  void select(int index) => currentIndex.value = index;

  void selectTab(BuyerTabId id) {
    final i = tabs.indexOf(id);
    if (i >= 0) currentIndex.value = i;
  }
}
