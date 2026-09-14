import 'package:bizops360_mobile/core/widgets/app_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_host.dart';

void main() {
  testWidgets('renders its label', (tester) async {
    await pumpInHost(
      tester,
      const AppStatusChip('Ticketed', tone: ChipTone.brand),
    );
    expect(find.text('Ticketed'), findsOneWidget);
  });

  testWidgets('renders in dark theme without throwing', (tester) async {
    await pumpInHost(
      tester,
      const AppStatusChip('Docs pending', tone: ChipTone.signal),
      brightness: Brightness.dark,
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Docs pending'), findsOneWidget);
  });
}
