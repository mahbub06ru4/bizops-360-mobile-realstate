import 'package:bizops360_mobile/core/permissions/permission_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PermissionResolver', () {
    const r = PermissionResolver(
      permissions: {'task.view', 'real_estate_project.view'},
      roles: {'manager'},
      enabledFeatures: {'tasks'},
      industry: 'real_estate',
    );

    test('can / canAny / canAll', () {
      expect(r.can('task.view'), isTrue);
      expect(r.can('task.create'), isFalse);
      expect(r.canAny(['task.create', 'real_estate_project.view']), isTrue);
      expect(r.canAll(['task.view', 'real_estate_project.view']), isTrue);
      expect(r.canAll(['task.view', 'task.create']), isFalse);
    });

    test('isManager and isRealEstate from roles / industry', () {
      expect(r.isManager, isTrue);
      expect(r.isRealEstate, isTrue);
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
      expect(r.allows('real_estate_project.view'), isTrue);
    });
  });
}
