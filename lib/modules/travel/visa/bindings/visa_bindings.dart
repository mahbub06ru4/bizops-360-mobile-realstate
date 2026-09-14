import 'package:get/get.dart';

import '../../../../core/config/env.dart';
import '../../../../core/network/api_client.dart';
import '../../../../data/datasources/visa_remote_datasource.dart';
import '../../../../data/repositories/fake_visa_repository.dart';
import '../../../../data/repositories/visa_repository_impl.dart';
import '../../../../domain/entities/visa_application.dart';
import '../../../../domain/repositories/visa_repository.dart';
import '../controllers/visa_detail_controller.dart';
import '../controllers/visa_queue_controller.dart';

/// Registers the real HTTP-backed repository, or the in-memory fake when
/// `Env.useFakeData` is on (the default until the API is reachable).
void _ensureVisaRepo() {
  if (Get.isRegistered<VisaRepository>()) return;
  final VisaRepository repo = Env.useFakeData
      ? FakeVisaRepository()
      : VisaRepositoryImpl(VisaRemoteDataSource(Get.find<ApiClient>()));
  Get.put<VisaRepository>(repo, permanent: true);
}

class VisaQueueBinding extends Bindings {
  @override
  void dependencies() {
    _ensureVisaRepo();
    Get.lazyPut<VisaQueueController>(() => VisaQueueController(Get.find()));
  }
}

class VisaDetailBinding extends Bindings {
  @override
  void dependencies() {
    _ensureVisaRepo();
    final arg = Get.arguments;
    final seed = arg is VisaApplication ? arg : null;
    final id = seed?.id ?? (arg is String ? arg : '');
    Get.lazyPut<VisaDetailController>(
      () => VisaDetailController(Get.find(), id, seed: seed),
    );
  }
}
