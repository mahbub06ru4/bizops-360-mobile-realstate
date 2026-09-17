import 'dart:async';

import 'package:get/get.dart';

import '../../../core/error/result.dart';
import '../../../core/paging/paging_controller.dart';
import '../../../domain/entities/employee.dart';
import '../../../domain/repositories/employee_repository.dart';

/// The employee directory: server-side search (debounced by `AppSearchField`)
/// and page-by-page loading via [PagingController] — every keystroke that
/// survives the debounce resets to page one with the new `q`.
class TeamController extends GetxController {
  TeamController(this._repo);

  final EmployeeRepository _repo;

  final RxString query = ''.obs;

  late final PagingController<Employee> paging = PagingController<Employee>(
    fetchPage: _fetchPage,
  );

  @override
  void onInit() {
    super.onInit();
    paging.reload();
  }

  Future<Result<List<Employee>>> _fetchPage(int page, int pageSize) {
    // PagingController pages are 0-based; the API paginator is 1-based.
    return _repo.employees(
      page: page + 1,
      perPage: pageSize,
      q: query.value.trim().isEmpty ? null : query.value.trim(),
    );
  }

  Future<void> load() => paging.reload();

  void onQueryChanged(String value) {
    query.value = value;
    unawaited(paging.reload());
  }
}
