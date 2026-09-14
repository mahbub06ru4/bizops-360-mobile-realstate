import 'package:bizops360_mobile/data/repositories/fake_leave_repository.dart';
import 'package:bizops360_mobile/domain/entities/leave_request.dart';
import 'package:bizops360_mobile/presentation/hr/controllers/approvals_controller.dart';
import 'package:bizops360_mobile/presentation/hr/controllers/leave_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('LeaveController.submit prepends a pending request', () async {
    final controller = LeaveController(FakeLeaveRepository());
    await controller.load();
    final before = controller.requests.value.valueOrNull!.length;

    final ok = await controller.submit(
      type: LeaveType.casual,
      from: DateTime(2026, 10, 3),
      to: DateTime(2026, 10, 5),
      reason: 'Trip',
    );
    await Future<void>.delayed(const Duration(milliseconds: 900));

    expect(ok, isTrue);
    final list = controller.requests.value.valueOrNull!;
    expect(list.length, before + 1);
    expect(list.first.status, LeaveStatus.pending);
  });

  test(
    'ApprovalsController.decide removes the request from the queue',
    () async {
      final controller = ApprovalsController(FakeLeaveRepository());
      await controller.load();
      final first = controller.pending.value.valueOrNull!.first;

      await controller.decide(first.id, approve: true);

      expect(
        controller.pending.value.valueOrNull!.any((r) => r.id == first.id),
        isFalse,
      );
    },
  );
}
