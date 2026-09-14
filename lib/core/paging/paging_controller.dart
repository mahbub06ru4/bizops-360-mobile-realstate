import 'package:get/get.dart';

import '../error/result.dart';

/// The non-generic surface [AppPagination] needs — kept separate from
/// [PagingController]'s type parameter so the footer widget can take any of
/// them regardless of item type.
abstract class Paging {
  RxBool get hasMore;
  RxBool get loadingMore;
  RxnString get loadMoreError;
  Future<void> loadMore();
}

/// Page-by-page loading for a list screen, once its repository exposes a
/// paginated endpoint (`page` / `per_page` or a cursor — adapt [fetchPage] to
/// whatever the API returns). Not wired into any screen yet: every list here
/// still fetches its full `Result<List<T>>` in one call. Reach for this the
/// day a real endpoint starts truncating and returning a next-page marker.
///
/// Usage: keep one alongside your existing `AsyncValue` state, call
/// `reload()` where you call `load()` today, read `items` instead of the
/// full list, and drop an `AppPagination(controller: paging)` as the last
/// item of the `ListView`.
class PagingController<T> extends GetxController implements Paging {
  PagingController({required this.fetchPage, this.pageSize = 20});

  /// Fetch one page (0-based). Return fewer than [pageSize] items — including
  /// none — to signal there is no next page.
  final Future<Result<List<T>>> Function(int page, int pageSize) fetchPage;
  final int pageSize;

  final RxList<T> items = <T>[].obs;

  @override
  final RxBool hasMore = true.obs;

  @override
  final RxBool loadingMore = false.obs;

  @override
  final RxnString loadMoreError = RxnString();

  int _page = 0;

  /// Reset to the first page and load it.
  Future<void> reload() async {
    _page = 0;
    items.clear();
    hasMore.value = true;
    loadMoreError.value = null;
    await loadMore();
  }

  @override
  Future<void> loadMore() async {
    if (loadingMore.value || !hasMore.value) return;
    loadingMore.value = true;
    loadMoreError.value = null;

    final result = await fetchPage(_page, pageSize);

    loadingMore.value = false;
    result.fold((page) {
      items.addAll(page);
      hasMore.value = page.length >= pageSize;
      _page++;
    }, (failure) => loadMoreError.value = failure.message);
  }
}
