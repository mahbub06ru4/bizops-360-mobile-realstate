import 'package:bizops360_mobile/data/repositories/fake_employee_repository.dart';
import 'package:bizops360_mobile/data/repositories/fake_holiday_repository.dart';
import 'package:bizops360_mobile/presentation/hr/controllers/holidays_controller.dart';
import 'package:bizops360_mobile/presentation/team/controllers/team_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'TeamController pages the directory and applies server-side search',
    () async {
      final c = TeamController(FakeEmployeeRepository());
      // onInit (which kicks off the first reload()) only runs under Get's
      // lifecycle — drive the paging controller directly in a plain unit test.
      await c.paging.reload();
      final total = c.paging.items.length;
      expect(total, greaterThan(0));
      expect(c.paging.hasMore.value, isFalse);

      c.query.value = 'rahim';
      await c.paging.reload();
      expect(c.paging.items, isNotEmpty);
      expect(
        c.paging.items.every(
          (e) =>
              e.name.toLowerCase().contains('rahim') ||
              e.employeeCode.toLowerCase().contains('rahim') ||
              (e.email?.toLowerCase().contains('rahim') ?? false),
        ),
        isTrue,
      );

      c.query.value = 'zzz-no-match';
      await c.paging.reload();
      expect(c.paging.items, isEmpty);
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
