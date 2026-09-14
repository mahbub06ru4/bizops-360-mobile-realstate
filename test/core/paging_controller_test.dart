import 'package:bizops360_mobile/core/error/failure.dart';
import 'package:bizops360_mobile/core/error/result.dart';
import 'package:bizops360_mobile/core/paging/paging_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PagingController', () {
    test('merges pages and stops once a short page comes back', () async {
      final pages = [
        List.generate(3, (i) => 'p0-$i'),
        List.generate(3, (i) => 'p1-$i'),
        List.generate(1, (i) => 'p2-$i'), // short — last page
      ];
      var call = 0;
      final c = PagingController<String>(
        pageSize: 3,
        fetchPage: (page, size) async => Result.ok(pages[call++]),
      );

      expect(c.hasMore.value, isTrue);
      await c.loadMore();
      expect(c.items, hasLength(3));
      expect(c.hasMore.value, isTrue);

      await c.loadMore();
      expect(c.items, hasLength(6));
      expect(c.hasMore.value, isTrue);

      await c.loadMore();
      expect(c.items, hasLength(7));
      expect(c.hasMore.value, isFalse);

      // Exhausted — a further call is a no-op, doesn't re-fetch.
      await c.loadMore();
      expect(c.items, hasLength(7));
      expect(call, 3);
    });

    test(
      'a concurrent loadMore call while one is in flight is ignored',
      () async {
        var calls = 0;
        final c = PagingController<int>(
          fetchPage: (page, size) async {
            calls++;
            await Future<void>.delayed(const Duration(milliseconds: 20));
            return Result.ok(List.generate(size, (i) => i));
          },
        );

        final a = c.loadMore();
        final b = c.loadMore();
        await Future.wait([a, b]);

        expect(calls, 1);
      },
    );

    test('a failed page surfaces the message and stays retryable', () async {
      var attempt = 0;
      final c = PagingController<int>(
        fetchPage: (page, size) async {
          attempt++;
          if (attempt == 1) {
            return const Result.err(NetworkFailure());
          }
          return Result.ok(List.generate(size, (i) => i));
        },
      );

      await c.loadMore();
      expect(c.loadMoreError.value, isNotNull);
      expect(c.items, isEmpty);
      expect(c.hasMore.value, isTrue);

      await c.loadMore();
      expect(c.loadMoreError.value, isNull);
      expect(c.items, isNotEmpty);
    });

    test('reload clears items and resets to the first page', () async {
      final c = PagingController<int>(
        pageSize: 2,
        fetchPage: (page, size) async =>
            Result.ok(List.generate(size, (i) => page * size + i)),
      );
      await c.loadMore();
      await c.loadMore();
      expect(c.items, [0, 1, 2, 3]);

      await c.reload();
      expect(c.items, [0, 1]);
    });
  });
}
