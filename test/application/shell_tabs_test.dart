import 'package:bizops360_mobile/application/navigation/shell_controller.dart';
import 'package:bizops360_mobile/core/permissions/permission_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shellTabsFor', () {
    test('travel manager sees Home · Customers · Visa · Tasks · More', () {
      const r = PermissionResolver(
        permissions: {'traveller.view', 'visa_application.view', 'task.view'},
        roles: {'manager'},
        industry: 'travel',
      );
      expect(shellTabsFor(r), [
        ShellTabId.home,
        ShellTabId.customers,
        ShellTabId.visa,
        ShellTabId.tasks,
        ShellTabId.workspace,
      ]);
    });

    test('non-travel tenant never gets the Visa tab', () {
      const r = PermissionResolver(
        permissions: {'customer.view', 'visa_application.view', 'task.view'},
        industry: 'consultancy',
      );
      expect(shellTabsFor(r), isNot(contains(ShellTabId.visa)));
      expect(shellTabsFor(r), contains(ShellTabId.customers));
    });

    test('a disabled feature hides its tab even with the permission', () {
      const r = PermissionResolver(
        permissions: {'visa_application.view', 'task.view'},
        enabledFeatures: {'travel_visa'}, // tasks feature off
        industry: 'travel',
      );
      final tabs = shellTabsFor(r);
      expect(tabs, contains(ShellTabId.visa));
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
