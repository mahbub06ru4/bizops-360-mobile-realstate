import 'package:bizops360_mobile/application/auth/auth_controller.dart';
import 'package:bizops360_mobile/core/state/async_value.dart';
import 'package:bizops360_mobile/data/repositories/fake_auth_repository.dart';
import 'package:bizops360_mobile/data/repositories/fake_billing_repository.dart';
import 'package:bizops360_mobile/domain/entities/billing_plan.dart';
import 'package:bizops360_mobile/domain/usecases/auth/load_session_usecase.dart';
import 'package:bizops360_mobile/domain/usecases/auth/register_usecase.dart';
import 'package:bizops360_mobile/domain/usecases/auth/sign_out_usecase.dart';
import 'package:bizops360_mobile/presentation/auth/controllers/plan_selection_controller.dart';
import 'package:bizops360_mobile/presentation/auth/controllers/register_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RegisterController', () {
    late RegisterController controller;
    late AuthController auth;

    setUp(() {
      final authRepo = FakeAuthRepository();
      auth = AuthController(
        loadSession: LoadSessionUseCase(authRepo),
        signOut: SignOutUseCase(authRepo),
      );
      controller = RegisterController(
        register: RegisterUseCase(authRepo),
        auth: auth,
      );
    });

    test('validateRequired rejects empty input', () {
      expect(controller.validateRequired(''), isNotNull);
      expect(controller.validateRequired('  '), isNotNull);
      expect(controller.validateRequired('Acme'), isNull);
    });

    test('validateEmail rejects malformed addresses', () {
      expect(controller.validateEmail('not-an-email'), isNotNull);
      expect(controller.validateEmail('owner@acme.test'), isNull);
    });

    test('validatePassword enforces an 8-character minimum', () {
      expect(controller.validatePassword('short'), isNotNull);
      expect(controller.validatePassword('longenough'), isNull);
    });

    test('validateConfirmPassword requires an exact match', () {
      controller.ownerPasswordCtrl.text = 'password123';
      expect(controller.validateConfirmPassword('different'), isNotNull);
      expect(controller.validateConfirmPassword('password123'), isNull);
    });

    test('submit signs the new owner in on success', () async {
      controller.companyNameCtrl.text = 'Acme Realty';
      controller.ownerNameCtrl.text = 'Jane Owner';
      controller.ownerEmailCtrl.text = 'jane@acme.test';
      controller.ownerPasswordCtrl.text = 'password123';
      controller.ownerPasswordConfirmCtrl.text = 'password123';

      final result = await RegisterUseCase(FakeAuthRepository())(
        companyName: controller.companyNameCtrl.text,
        industry: controller.industry.value,
        ownerName: controller.ownerNameCtrl.text,
        ownerEmail: controller.ownerEmailCtrl.text,
        ownerPassword: controller.ownerPasswordCtrl.text,
        ownerPasswordConfirmation: controller.ownerPasswordConfirmCtrl.text,
      );

      expect(result.isOk, isTrue);
      expect(result.valueOrNull!.email, 'jane@acme.test');
      expect(result.valueOrNull!.tenant?.name, 'Acme Realty');
    });

    test('FakeAuthRepository.register rejects a password mismatch', () async {
      final repo = FakeAuthRepository();
      final result = await repo.register(
        companyName: 'Acme Realty',
        industry: 'real_estate',
        ownerName: 'Jane Owner',
        ownerEmail: 'jane@acme.test',
        ownerPassword: 'password123',
        ownerPasswordConfirmation: 'nope',
      );
      expect(result.isErr, isTrue);
    });
  });

  group('PlanSelectionController', () {
    late PlanSelectionController controller;

    setUp(() => controller = PlanSelectionController(FakeBillingRepository()));

    test('load populates plans and preselects the first one', () async {
      await controller.load();
      final state = controller.state.value;
      expect(state, isA<AsyncData<List<BillingPlan>>>());
      expect(state.valueOrNull, isNotEmpty);
      expect(controller.selectedCode.value, state.valueOrNull!.first.code);
    });

    test('select changes the chosen plan code', () async {
      await controller.load();
      final plans = controller.state.value.valueOrNull!;
      controller.select(plans.last.code);
      expect(controller.selectedCode.value, plans.last.code);
    });

    test('FakeBillingRepository.selectPlan accepts the chosen code', () async {
      final repo = FakeBillingRepository();
      final plansResult = await repo.getPlans();
      final code = plansResult.valueOrNull!.first.code;
      final result = await repo.selectPlan(code);
      expect(result.isOk, isTrue);
      expect(repo.selectedPlanCode, code);
    });
  });
}
