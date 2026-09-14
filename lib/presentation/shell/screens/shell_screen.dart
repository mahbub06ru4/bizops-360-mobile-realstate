import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../application/navigation/shell_controller.dart';
import '../../../core/localization/translation_keys.dart';
import '../../../modules/travel/visa/screens/visa_queue_screen.dart';
import '../../customers/screens/customers_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../tasks/screens/tasks_screen.dart';
import '../../workspace/screens/workspace_screen.dart';

/// The signed-in container: a permission-driven bottom nav over an
/// [IndexedStack] of the destination roots.
class ShellScreen extends GetView<ShellController> {
  const ShellScreen({super.key});

  static ({String labelKey, IconData icon, IconData selectedIcon, Widget page})
  _spec(ShellTabId id) {
    return switch (id) {
      ShellTabId.home => (
        labelKey: Tr.navHome,
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        page: const HomeScreen(),
      ),
      ShellTabId.customers => (
        labelKey: Tr.navCustomers,
        icon: Icons.people_outline,
        selectedIcon: Icons.people,
        page: const CustomersScreen(),
      ),
      ShellTabId.visa => (
        labelKey: Tr.navVisa,
        icon: Icons.description_outlined,
        selectedIcon: Icons.description,
        page: const VisaQueueScreen(),
      ),
      ShellTabId.tasks => (
        labelKey: Tr.navTasks,
        icon: Icons.check_circle_outline,
        selectedIcon: Icons.check_circle,
        page: const TasksScreen(),
      ),
      ShellTabId.workspace => (
        labelKey: Tr.navMore,
        icon: Icons.grid_view_outlined,
        selectedIcon: Icons.grid_view,
        page: const WorkspaceScreen(),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final specs = controller.tabs.map(_spec).toList();
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
