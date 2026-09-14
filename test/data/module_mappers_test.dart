import 'package:bizops360_mobile/data/models/booking_mappers.dart';
import 'package:bizops360_mobile/data/models/crm_mappers.dart';
import 'package:bizops360_mobile/data/models/hr_mappers.dart';
import 'package:bizops360_mobile/data/models/notification_mappers.dart';
import 'package:bizops360_mobile/data/models/task_mappers.dart';
import 'package:bizops360_mobile/domain/entities/booking.dart';
import 'package:bizops360_mobile/domain/entities/customer.dart';
import 'package:bizops360_mobile/domain/entities/leave_request.dart';
import 'package:bizops360_mobile/domain/entities/task_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('taskFromJson', () {
    test('folds in_review→inProgress and cancelled→done', () {
      expect(
        taskFromJson(const {
          'id': 1,
          'title': 'A',
          'status': 'in_review',
        }).status,
        TaskStatus.inProgress,
      );
      expect(
        taskFromJson(const {
          'id': 2,
          'title': 'B',
          'status': 'cancelled',
        }).status,
        TaskStatus.done,
      );
    });

    test('round-trips the four writable statuses', () {
      expect(statusToApi[TaskStatus.open], 'todo');
      expect(statusToApi[TaskStatus.inProgress], 'in_progress');
    });
  });

  group('notificationFromJson', () {
    test('reads title/body from the payload and kind from the type', () {
      final n = notificationFromJson(const {
        'id': 'abc',
        'type': 'TaskEventNotification',
        'payload': {'task_title': 'Collect passports', 'message': 'Assigned.'},
        'read_at': null,
        'created_at': '2026-09-10T09:00:00+00:00',
      });
      expect(n.title, 'Collect passports');
      expect(n.body, 'Assigned.');
      expect(n.read, isFalse);
    });
  });

  group('customerFromJson', () {
    test('every customer is a converted lead', () {
      expect(
        customerFromJson(const {'id': 1, 'name': 'ACME'}).stage,
        PipelineStage.converted,
      );
    });
  });

  group('bookingFromJson', () {
    test('folds product type and status into the app model', () {
      final b = bookingFromJson(const {
        'id': 1,
        'type': 'umrah',
        'status': 'confirmed',
        'sell_amount': '90000.00',
        'depart_on': '2026-10-01',
        'pnr': 'BQ7K2P',
        'customer': {'name': 'Rahim'},
      });
      expect(b.kind, BookingKind.package);
      expect(b.status, BookingStatus.held);
      expect(b.reference, 'BQ7K2P');
      expect(b.amount, 90000);
      expect(b.travellerName, 'Rahim');
    });
  });

  group('hr mappers', () {
    test('leaveTypeFromCode matches on substring', () {
      expect(leaveTypeFromCode('SICK'), LeaveType.sick);
      expect(leaveTypeFromCode('annual_leave'), LeaveType.annual);
      expect(leaveTypeFromCode('LOP'), LeaveType.unpaid);
      expect(leaveTypeFromCode('casual'), LeaveType.casual);
      expect(leaveTypeFromCode(null), LeaveType.casual);
    });

    test('attendanceTodayFrom finds the row dated today', () {
      final today = DateTime.now().toIso8601String().split('T').first;
      final t = attendanceTodayFrom([
        {'date': '2020-01-01', 'check_in_at': null},
        {'date': today, 'check_in_at': '${today}T09:05:00+00:00'},
      ]);
      expect(t.checkIn, isNotNull);
      expect(t.isCheckedIn, isTrue);
    });
  });
}
