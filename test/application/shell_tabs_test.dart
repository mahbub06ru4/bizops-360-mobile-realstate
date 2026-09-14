import 'package:bizops360_mobile/application/navigation/shell_controller.dart';
import 'package:bizops360_mobile/core/permissions/permission_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shellTabsFor', () {
    test(
      'real-estate manager sees Home · Customers · Projects · Tasks · More',
      () {
        const r = PermissionResolver(
          permissions: {
            'customer.view',
            'real_estate_project.view',
            'task.view',
          },
          roles: {'manager'},
          industry: 'real_estate',
        );
        expect(shellTabsFor(r), [
          ShellTabId.home,
          ShellTabId.customers,
          ShellTabId.projects,
          ShellTabId.tasks,
          ShellTabId.workspace,
        ]);
      },
    );

    test('a non-real-estate tenant never gets the Projects tab', () {
      const r = PermissionResolver(
        permissions: {'customer.view', 'real_estate_project.view', 'task.view'},
        industry: 'consultancy',
      );
      expect(shellTabsFor(r), isNot(contains(ShellTabId.projects)));
      expect(shellTabsFor(r), contains(ShellTabId.customers));
    });

    test('a disabled feature hides its tab even with the permission', () {
      const r = PermissionResolver(
        permissions: {'real_estate_project.view', 'task.view'},
        enabledFeatures: {'real_estate_projects'}, // tasks feature off
        industry: 'real_estate',
      );
      final tabs = shellTabsFor(r);
      expect(tabs, contains(ShellTabId.projects));
      expect(tabs, isNot(contains(ShellTabId.tasks)));
    });

    test('minimal session still gets Home and More', () {
      expect(shellTabsFor(const PermissionResolver.empty()), [
        ShellTabId.home,
        ShellTabId.workspace,
      ]);
    });
  });
}
