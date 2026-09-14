import 'package:bizops360_mobile/data/repositories/fake_employee_repository.dart';
import 'package:bizops360_mobile/data/repositories/fake_holiday_repository.dart';
import 'package:bizops360_mobile/presentation/hr/controllers/holidays_controller.dart';
import 'package:bizops360_mobile/presentation/team/controllers/team_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'TeamController search matches name, designation or department',
    () async {
      final c = TeamController(FakeEmployeeRepository());
      await c.load();
      final total = c.visible.length;
      expect(total, greaterThan(0));

      c.query.value = 'sales';
      expect(c.visible, isNotEmpty);
      expect(
        c.visible.every(
          (e) =>
              e.name.toLowerCase().contains('sales') ||
              (e.designation?.toLowerCase().contains('sales') ?? false) ||
              (e.department?.toLowerCase().contains('sales') ?? false),
        ),
        isTrue,
      );

      c.query.value = 'zzz-no-match';
      expect(c.visible, isEmpty);
    },
  );

  test(
    'HolidaysController splits upcoming from past and stays sorted',
    () async {
      final c = HolidaysController(FakeHolidayRepository());
      await c.load();

      final all = c.state.value.valueOrNull!;
      expect(c.upcoming.length + c.past.length, all.length);
      expect(c.upcoming.every((h) => !h.isPast), isTrue);
      expect(c.past.every((h) => h.isPast), isTrue);

      for (var i = 1; i < all.length; i++) {
        expect(all[i].date.isBefore(all[i - 1].date), isFalse);
      }
    },
  );
}
