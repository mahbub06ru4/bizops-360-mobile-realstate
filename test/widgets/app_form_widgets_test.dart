import 'package:bizops360_mobile/core/paging/paging_controller.dart';
import 'package:bizops360_mobile/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_host.dart';

void main() {
  group('AppSearchField', () {
    testWidgets('debounces onChanged and offers a clear button', (
      tester,
    ) async {
      final values = <String>[];
      await pumpInHost(
        tester,
        AppSearchField(
          hint: 'Search',
          debounce: const Duration(milliseconds: 50),
          onChanged: values.add,
        ),
      );

      await tester.enterText(find.byType(TextField), 'ra');
      await tester.enterText(find.byType(TextField), 'rahim');
      // Not yet fired — still inside the debounce window.
      await tester.pump(const Duration(milliseconds: 20));
      expect(values, isEmpty);

      await tester.pump(const Duration(milliseconds: 60));
      expect(values, ['rahim']);

      expect(find.byIcon(Icons.close), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      expect(values, ['rahim', '']);
      expect(find.byIcon(Icons.close), findsNothing);
    });
  });

  group('AppDropdown', () {
    testWidgets('shows each item and reports a selection', (tester) async {
      String? selected;
      await pumpInHost(
        tester,
        AppDropdown<String>(
          label: 'Category',
          value: 'a',
          items: const [
            AppDropdownItem('a', 'Alpha'),
            AppDropdownItem('b', 'Beta'),
          ],
          onChanged: (v) => selected = v,
        ),
      );

      expect(find.text('Alpha'), findsOneWidget);

      await tester.tap(find.byType(AppDropdown<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Beta').last);
      await tester.pumpAndSettle();

      expect(selected, 'b');
    });
  });

  group('AppPagination', () {
    testWidgets('hides once the controller has no more pages', (tester) async {
      final c = PagingController<int>(
        fetchPage: (page, size) async => throw UnimplementedError(),
      );
      c.hasMore.value = false;

      await pumpInHost(tester, AppPagination(controller: c));
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows a spinner while a page is loading', (tester) async {
      final c = PagingController<int>(
        fetchPage: (page, size) async => throw UnimplementedError(),
      );
      c.loadingMore.value = true;

      await pumpInHost(tester, AppPagination(controller: c));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows a retry action after a failed page', (tester) async {
      final c = PagingController<int>(
        fetchPage: (page, size) async => throw UnimplementedError(),
      );
      c.loadMoreError.value = 'Request failed';

      await pumpInHost(tester, AppPagination(controller: c));
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });
}
