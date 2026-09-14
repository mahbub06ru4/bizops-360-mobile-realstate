import 'package:bizops360_mobile/application/auth/auth_controller.dart';
import 'package:bizops360_mobile/application/permissions/permissions_controller.dart';
import 'package:bizops360_mobile/core/permissions/can.dart';
import 'package:bizops360_mobile/data/repositories/fake_auth_repository.dart';
import 'package:bizops360_mobile/domain/entities/auth_user.dart';
import 'package:bizops360_mobile/domain/entities/tenant.dart';
import 'package:bizops360_mobile/domain/usecases/auth/load_session_usecase.dart';
import 'package:bizops360_mobile/domain/usecases/auth/sign_out_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

AuthUser _user({required String industry}) => AuthUser(
  id: 1,
  name: 'Owner',
  email: 'owner@x.test',
  roles: const ['owner'],
  permissions: const ['visa_application.view', 'traveller.view'],
  tenant: Tenant(id: 1, name: 'X', slug: 'x', industry: industry),
);

void main() {
  late AuthController auth;

  setUp(() {
    final repo = FakeAuthRepository();
    auth = AuthController(
      loadSession: LoadSessionUseCase(repo),
      signOut: SignOutUseCase(repo),
    );
    Get.put<AuthController>(auth);
    Get.put<PermissionsController>(PermissionsController(auth));
  });

  tearDown(Get.reset);

  testWidgets('Can(travelOnly: true) hides for a non-travel tenant', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Can(
          'visa_application.view',
          travelOnly: true,
          child: Text('travel-thing'),
        ),
      ),
    );

    auth.setUser(_user(industry: 'real_estate'));
    await tester.pump();
    expect(find.text('travel-thing'), findsNothing);

    auth.setUser(_user(industry: 'travel'));
    await tester.pump();
    expect(find.text('travel-thing'), findsOneWidget);
  });

  testWidgets('without travelOnly the permission alone decides', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Can('visa_application.view', child: Text('perm-thing')),
      ),
    );

    auth.setUser(_user(industry: 'real_estate'));
    await tester.pump();
    expect(find.text('perm-thing'), findsOneWidget);
  });
}
