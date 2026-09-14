import 'package:bizops360_mobile/data/repositories/fake_crm_repository.dart';
import 'package:bizops360_mobile/domain/entities/customer.dart';
import 'package:bizops360_mobile/domain/entities/follow_up.dart';
import 'package:bizops360_mobile/presentation/crm/controllers/customers_controller.dart';
import 'package:bizops360_mobile/presentation/crm/controllers/follow_ups_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CustomersController filters by stage and query', () async {
    final c = CustomersController(FakeCrmRepository());
    await c.load();
    final total = c.visible.length;

    c.toggleStage(PipelineStage.newLead);
    expect(c.visible.every((x) => x.stage == PipelineStage.newLead), isTrue);
    expect(c.visible.length, lessThan(total));

    c.toggleStage(PipelineStage.newLead); // clear
    c.query.value = 'rahim';
    expect(c.visible, hasLength(1));
  });

  test('FollowUpsController buckets and completes with an outcome', () async {
    final c = FollowUpsController(FakeCrmRepository());
    await c.load();

    expect(c.countOf(FollowUpBucket.overdue), greaterThan(0));
    final target = c.bucket(FollowUpBucket.overdue).first;

    await c.complete(target.id, FollowUpOutcome.rescheduled);

    final done = c.bucket(FollowUpBucket.done);
    expect(
      done.any(
        (f) => f.id == target.id && f.outcome == FollowUpOutcome.rescheduled,
      ),
      isTrue,
    );
  });
}
