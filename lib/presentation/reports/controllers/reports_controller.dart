import 'package:get/get.dart';

import '../../../core/state/async_value.dart';
import '../../../domain/entities/report_overview.dart';
import '../../../domain/repositories/report_repository.dart';

class ReportsController extends GetxController {
  ReportsController(this._repo);

  final ReportRepository _repo;

  final Rx<AsyncValue<ReportOverview>> state =
      const AsyncValue<ReportOverview>.loading().obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = const AsyncValue.loading();
    state.value = (await _repo.overview()).fold(
      AsyncValue.data,
      AsyncValue.error,
    );
  }
}
