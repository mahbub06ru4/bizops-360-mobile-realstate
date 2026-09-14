import 'package:bizops360_mobile/core/permissions/permission_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PermissionResolver', () {
    const r = PermissionResolver(
      permissions: {'task.view', 'visa_application.view'},
      roles: {'manager'},
      enabledFeatures: {'tasks'},
      industry: 'travel',
    );

    test('can / canAny / canAll', () {
      expect(r.can('task.view'), isTrue);
      expect(r.can('task.create'), isFalse);
      expect(r.canAny(['task.create', 'visa_application.view']), isTrue);
      expect(r.canAll(['task.view', 'visa_application.view']), isTrue);
      expect(r.canAll(['task.view', 'task.create']), isFalse);
    });

    test('isManager and isTravel from roles / industry', () {
      expect(r.isManager, isTrue);
      expect(r.isTravel, isTrue);
      expect(const PermissionResolver.empty().isManager, isFalse);
    });

    test('featureEnabled: known flag, unknown flag, empty set', () {
      expect(r.featureEnabled('tasks'), isTrue);
      expect(r.featureEnabled('crm'), isFalse);
      // No flags loaded yet → treat everything as on.
      expect(const PermissionResolver().featureEnabled('crm'), isTrue);
    });

    test('allows combines permission and feature', () {
      expect(r.allows('task.view', feature: 'tasks'), isTrue);
      expect(r.allows('task.view', feature: 'crm'), isFalse);
      expect(r.allows('visa_application.view'), isTrue);
    });
  });
}
