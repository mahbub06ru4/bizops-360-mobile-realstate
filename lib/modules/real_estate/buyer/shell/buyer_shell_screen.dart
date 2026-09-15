import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/localization/translation_keys.dart';
import '../browse/screens/browse_screen.dart';
import '../my_properties/screens/my_properties_screen.dart';
import '../profile/screens/buyer_profile_screen.dart';
import '../saved/screens/saved_screen.dart';
import 'buyer_shell_controller.dart';

/// The buyer persona's container — Browse | Saved | My Properties | Profile
/// (roadmap §7 Phase 2), the buyer-mode analogue of `ShellScreen` for staff.
/// Deliberately not permission-driven: a buyer session carries no
/// roles/permissions to vary the tab set by.
class BuyerShellScreen extends GetView<BuyerShellController> {
  const BuyerShellScreen({super.key});

  static ({String labelKey, IconData icon, IconData selectedIcon, Widget page})
  _spec(BuyerTabId id) {
    return switch (id) {
      BuyerTabId.browse => (
        labelKey: Tr.buyerNavBrowse,
        icon: Icons.explore_outlined,
        selectedIcon: Icons.explore,
        page: const BrowseScreen(),
      ),
      BuyerTabId.saved => (
        labelKey: Tr.buyerNavSaved,
        icon: Icons.bookmark_outline,
        selectedIcon: Icons.bookmark,
        page: const SavedScreen(),
      ),
      BuyerTabId.myProperties => (
        labelKey: Tr.buyerNavMyProperties,
        icon: Icons.apartment_outlined,
        selectedIcon: Icons.apartment,
        page: const MyPropertiesScreen(),
      ),
      BuyerTabId.profile => (
        labelKey: Tr.buyerNavProfile,
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
        page: const BuyerProfileScreen(),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final specs = BuyerShellController.tabs.map(_spec).toList();
      final index = controller.currentIndex.value.clamp(0, specs.length - 1);

      return Scaffold(
        body: SafeArea(
          child: IndexedStack(
            index: index,
            children: [for (final s in specs) s.page],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: controller.select,
          destinations: [
            for (final s in specs)
              NavigationDestination(
                icon: Icon(s.icon),
                selectedIcon: Icon(s.selectedIcon),
                label: s.labelKey.tr,
              ),
          ],
        ),
      );
    });
  }
}
