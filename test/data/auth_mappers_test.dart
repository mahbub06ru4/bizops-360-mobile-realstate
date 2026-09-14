import 'package:bizops360_mobile/data/models/auth_mappers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('authUserFromJson', () {
    test('parses the login/me data envelope', () {
      final user = authUserFromJson(const {
        'id': 7,
        'name': 'Rahim Uddin',
        'email': 'rahim@wanderlust.test',
        'roles': ['staff'],
        'permissions': ['booking.view', 'booking.create', 'traveller.view'],
        'tenant': {
          'id': 1,
          'name': 'Wanderlust Travel',
          'slug': 'wanderlust',
          'industry': 'travel',
        },
      });

      expect(user.id, 7);
      expect(user.email, 'rahim@wanderlust.test');
      expect(user.can('booking.create'), isTrue);
      expect(user.can('invoice.refund'), isFalse);
      expect(user.isManager, isFalse);
      expect(user.tenant?.isTravel, isTrue);
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
