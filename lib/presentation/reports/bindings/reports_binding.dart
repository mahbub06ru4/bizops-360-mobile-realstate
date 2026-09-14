import 'package:get/get.dart';

import '../../../data/datasources/report_remote_datasource.dart';
import '../../../data/repositories/fake_report_repository.dart';
import '../../../data/repositories/repo_registry.dart';
import '../../../data/repositories/report_repository_impl.dart';
import '../../../domain/repositories/report_repository.dart';
import '../controllers/reports_controller.dart';

class ReportsBinding extends Bindings {
  @override
  void dependencies() {
    registerRepo<ReportRepository>(
      (client) => ReportRepositoryImpl(ReportRemoteDataSource(client)),
      FakeReportRepository.new,
    );
    Get.lazyPut<ReportsController>(() => ReportsController(Get.find()));
  }
}
