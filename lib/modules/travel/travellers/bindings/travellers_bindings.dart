import 'package:get/get.dart';

import '../../../../core/config/env.dart';
import '../../../../core/network/api_client.dart';
import '../../../../data/datasources/traveller_remote_datasource.dart';
import '../../../../data/repositories/fake_traveller_repository.dart';
import '../../../../data/repositories/traveller_repository_impl.dart';
import '../../../../domain/entities/traveller.dart';
import '../../../../domain/repositories/traveller_repository.dart';
import '../controllers/traveller_detail_controller.dart';
import '../controllers/travellers_controller.dart';

/// Registers the real HTTP-backed repository, or the in-memory fake when
/// `Env.useFakeData` is on (the default until the API is reachable).
void _ensureRepo() {
  if (Get.isRegistered<TravellerRepository>()) return;
  final TravellerRepository repo = Env.useFakeData
      ? FakeTravellerRepository()
      : TravellerRepositoryImpl(
          TravellerRemoteDataSource(Get.find<ApiClient>()),
        );
  Get.put<TravellerRepository>(repo, permanent: true);
}

class TravellersBinding extends Bindings {
  @override
  void dependencies() {
    _ensureRepo();
    Get.lazyPut<TravellersController>(() => TravellersController(Get.find()));
  }
}

class TravellerDetailBinding extends Bindings {
  @override
  void dependencies() {
    _ensureRepo();
    final arg = Get.arguments;
    final seed = arg is Traveller ? arg : null;
    final id = seed?.id ?? (arg is String ? arg : '');
    Get.lazyPut<TravellerDetailController>(
      () => TravellerDetailController(Get.find(), id, seed: seed),
    );
  }
}
