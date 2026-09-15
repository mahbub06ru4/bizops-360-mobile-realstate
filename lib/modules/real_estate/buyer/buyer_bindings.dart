import 'package:get/get.dart';

import '../../../core/config/env.dart';
import '../../../core/network/api_client.dart';
import '../../../data/datasources/buyer_remote_datasource.dart';
import '../../../data/repositories/buyer_repository_impl.dart';
import '../../../data/repositories/fake_buyer_repository.dart';
import '../../../domain/repositories/buyer_repository.dart';
import '../../../domain/repositories/real_estate_project_repository.dart';
import '../projects/bindings/real_estate_bindings.dart';
import 'browse/controllers/browse_controller.dart';
import 'compare/controllers/compare_controller.dart';
import 'my_properties/controllers/my_properties_controller.dart';
import 'profile/controllers/buyer_profile_controller.dart';
import 'saved/controllers/saved_controller.dart';
import 'shell/buyer_shell_controller.dart';

/// Public so any buyer route can pull `BuyerRepository` in directly, mirroring
/// `ensureRealEstateProjectRepo` for the seller/staff side.
void ensureBuyerRepo() {
  if (Get.isRegistered<BuyerRepository>()) return;
  ensureRealEstateProjectRepo();
  Get.put<BuyerRepository>(
    Env.useFakeData
        ? FakeBuyerRepository(Get.find<RealEstateProjectRepository>())
        : BuyerRepositoryImpl(BuyerRemoteDataSource(Get.find<ApiClient>())),
    permanent: true,
  );
}

class BrowseBinding extends Bindings {
  @override
  void dependencies() {
    ensureBuyerRepo();
    Get.lazyPut<BrowseController>(() => BrowseController(Get.find()));
  }
}

class SavedBinding extends Bindings {
  @override
  void dependencies() {
    ensureBuyerRepo();
    Get.lazyPut<SavedController>(() => SavedController(Get.find(), Get.find()));
  }
}

/// `/buyer/compare` — a real route (not a shell tab), so it reads the
/// selected project ids straight out of the arguments `SavedScreen` passed to
/// `Get.toNamed`.
class CompareBinding extends Bindings {
  @override
  void dependencies() {
    ensureBuyerRepo();
    final ids = (Get.arguments as List?)?.cast<String>() ?? const <String>[];
    Get.lazyPut<CompareController>(() => CompareController(Get.find(), ids));
  }
}

class MyPropertiesBinding extends Bindings {
  @override
  void dependencies() {
    ensureBuyerRepo();
    Get.lazyPut<MyPropertiesController>(
      () => MyPropertiesController(Get.find()),
    );
  }
}

class BuyerProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BuyerProfileController>(BuyerProfileController.new);
  }
}

/// The buyer shell embeds its tab screens as widgets (not routes), so their
/// feature bindings run here rather than per-route — mirroring `ShellBinding`
/// for the staff side.
class BuyerShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BuyerShellController>(BuyerShellController.new);
    BrowseBinding().dependencies();
    SavedBinding().dependencies();
    MyPropertiesBinding().dependencies();
    BuyerProfileBinding().dependencies();
  }
}
