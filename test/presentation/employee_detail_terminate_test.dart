import 'package:bizops360_mobile/core/localization/translation_keys.dart';
import 'package:bizops360_mobile/core/widgets/widgets.dart';
import 'package:bizops360_mobile/data/repositories/fake_employee_repository.dart';
import 'package:bizops360_mobile/domain/entities/employee.dart';
import 'package:bizops360_mobile/presentation/team/controllers/employee_detail_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../support/test_host.dart';

void main() {
  testWidgets('terminate asks for confirmation and only acts once confirmed', (
    tester,
  ) async {
    final repo = FakeEmployeeRepository();
    final controller = EmployeeDetailController(repo, 'e1');
    await controller.load();
    expect(controller.state.value.valueOrNull?.status, EmploymentStatus.active);

    await pumpInHost(
      tester,
      AppButton(
        label: 'Terminate',
        onPressed: () async {
          await controller.terminate();
        },
      ),
    );

    // Tap the action button — a confirmation dialog appears, and the
    // employee is untouched until it's answered.
    await tester.tap(find.text('Terminate'));
    await tester.pumpAndSettle();
    expect(find.text(Tr.empTerminateConfirmTitle.tr), findsOneWidget);
    expect(controller.state.value.valueOrNull?.status, EmploymentStatus.active);

    // Cancel leaves the employee untouched.
    await tester.tap(find.text(Tr.cancel.tr));
    await tester.pumpAndSettle();
    expect(controller.state.value.valueOrNull?.status, EmploymentStatus.active);

    // Confirming actually terminates.
    await tester.tap(find.text('Terminate'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Tr.empTerminate.tr).last);
    await tester.pumpAndSettle();

    expect(
      controller.state.value.valueOrNull?.status,
      EmploymentStatus.terminated,
    );

    // The success snackbar schedules its own auto-dismiss timer, then an
    // exit animation — elapse past the timer, then let that animation
    // finish before the test tears down the widget tree.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
