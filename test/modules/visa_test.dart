import 'package:bizops360_mobile/core/error/failure.dart';
import 'package:bizops360_mobile/data/repositories/fake_visa_repository.dart';
import 'package:bizops360_mobile/domain/entities/visa_application.dart';
import 'package:bizops360_mobile/modules/travel/visa/controllers/visa_detail_controller.dart';
import 'package:bizops360_mobile/modules/travel/visa/controllers/visa_queue_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('queue filters by stage', () async {
    final c = VisaQueueController(FakeVisaRepository());
    await c.load();
    final all = c.visible.length;
    c.toggleFilter(VisaStage.processing);
    expect(c.visible.every((a) => a.stage == VisaStage.processing), isTrue);
    expect(c.visible.length, lessThan(all));
  });

  test('submit is blocked until every doc is collected', () async {
    final repo = FakeVisaRepository();
    final c = VisaDetailController(repo, 'v2'); // seeded with 3/7 docs
    await c.reload();

    await c.submit();
    expect(c.state.value.valueOrNull!.stage, isNot(VisaStage.submitted));

    // Collect the rest, then submit succeeds.
    for (final d in [...c.state.value.valueOrNull!.docs]) {
      if (!d.collected) await c.toggleDoc(d.name);
    }
    await c.submit();
    expect(c.state.value.valueOrNull!.stage, VisaStage.submitted);
  });

  test('decide moves an approved case to the terminal stage', () async {
    final c = VisaDetailController(FakeVisaRepository(), 'v3'); // processing
    await c.reload();
    await c.decide(approved: true);
    expect(c.state.value.valueOrNull!.stage, VisaStage.approved);
    expect(c.state.value.valueOrNull!.decisionAt, isNotNull);
  });

  test('byId on a missing case yields NotFoundFailure', () async {
    final r = await FakeVisaRepository().byId('nope');
    expect(r.failureOrNull, isA<NotFoundFailure>());
  });
}
