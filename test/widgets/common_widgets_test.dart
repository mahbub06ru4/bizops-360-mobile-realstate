import 'package:bizops360_mobile/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_host.dart';

void main() {
  group('AppButton', () {
    testWidgets('shows label and fires onPressed', (tester) async {
      var tapped = false;
      await pumpInHost(
        tester,
        AppButton(label: 'Continue', onPressed: () => tapped = true),
      );
      await tester.tap(find.text('Continue'));
      expect(tapped, isTrue);
    });

    testWidgets('swallows taps while loading', (tester) async {
      var tapped = false;
      await pumpInHost(
        tester,
        AppButton(label: 'Save', loading: true, onPressed: () => tapped = true),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(AppButton));
      expect(tapped, isFalse);
    });
  });

  testWidgets('AppTextField toggles obscure', (tester) async {
    await pumpInHost(
      tester,
      const AppTextField(label: 'Password', obscure: true),
    );
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });

  testWidgets('AppEmptyState renders a default title', (tester) async {
    await pumpInHost(tester, const AppEmptyState());
    expect(find.text('Nothing here yet'), findsOneWidget);
  });

  testWidgets('AppErrorState retry button calls back', (tester) async {
    var retried = false;
    await pumpInHost(
      tester,
      AppErrorState(onRetry: () => retried = true),
      brightness: Brightness.dark,
    );
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });

  testWidgets('AppBadge hides at zero, shows capped count', (tester) async {
    await pumpInHost(tester, const AppBadge(count: 0));
    expect(find.textContaining('+'), findsNothing);

    await pumpInHost(tester, const AppBadge(count: 42));
    expect(find.text('9+'), findsOneWidget);
  });

  testWidgets('AppStatusChip renders label in both themes', (tester) async {
    await pumpInHost(
      tester,
      const AppStatusChip('Submitted', tone: ChipTone.info),
      brightness: Brightness.dark,
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Submitted'), findsOneWidget);
  });
}
