import 'package:bizops360_mobile/data/models/auth_mappers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('authUserFromJson', () {
    test('parses the login/me data envelope', () {
      final user = authUserFromJson(const {
        'id': 7,
        'name': 'Rahim Uddin',
        'email': 'rahim@greenland.test',
        'roles': ['staff'],
        'permissions': [
          'real_estate_project.view',
          'real_estate_project.create',
        ],
        'tenant': {
          'id': 1,
          'name': 'Greenland Properties',
          'slug': 'greenland',
          'industry': 'real_estate',
        },
      });

      expect(user.id, 7);
      expect(user.email, 'rahim@greenland.test');
      expect(user.can('real_estate_project.create'), isTrue);
      expect(user.can('invoice.refund'), isFalse);
      expect(user.isManager, isFalse);
      expect(user.tenant?.isRealEstate, isTrue);
      expect(user.initials, 'RU');
    });

    test('treats owner/admin/manager roles as a manager', () {
      final manager = authUserFromJson(const {
        'id': 2,
        'name': 'Nadia Haque',
        'email': 'nadia@wanderlust.test',
        'roles': ['manager'],
        'permissions': <String>[],
      });

      expect(manager.isManager, isTrue);
      expect(manager.tenant, isNull);
    });

    test('tolerates missing roles and permissions', () {
      final user = authUserFromJson(const {
        'id': 1,
        'name': 'X',
        'email': 'x@y.test',
      });
      expect(user.roles, isEmpty);
      expect(user.permissions, isEmpty);
    });
  });
}
