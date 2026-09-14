import 'package:get/get.dart';

import '../core/config/env.dart';
import '../core/network/api_client.dart';
import '../core/network/auth_interceptor.dart';
import '../core/storage/kv_store.dart';
import '../core/storage/secure_store.dart';
import '../data/datasources/auth_remote_datasource.dart';
import '../data/datasources/device_remote_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/device_repository_impl.dart';
import '../data/repositories/fake_auth_repository.dart';
import '../data/repositories/fake_device_repository.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/device_repository.dart';
import '../domain/usecases/auth/load_session_usecase.dart';
import '../domain/usecases/auth/sign_in_usecase.dart';
import '../domain/usecases/auth/sign_out_usecase.dart';
import 'auth/auth_controller.dart';
import 'permissions/permissions_controller.dart';
import 'settings/settings_controller.dart';

/// Wires the object graph once, before the first route. Order matters: storage →
/// interceptor → client → repository → use cases → session controller. The
/// interceptor's unauthorized hook resolves [AuthController] lazily to avoid a
/// cycle. `Env.useFakeData` swaps the real repository for the in-memory fake.
class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<KvStore>(KvStore(), permanent: true);
    Get.put<SecureStore>(SecureStore(), permanent: true);
    Get.put<SettingsController>(
      SettingsController(Get.find()),
      permanent: true,
    );

    _wireAuthRepository();

    Get.put<SignInUseCase>(SignInUseCase(Get.find()), permanent: true);
    Get.put<LoadSessionUseCase>(
      LoadSessionUseCase(Get.find()),
      permanent: true,
    );
    Get.put<SignOutUseCase>(SignOutUseCase(Get.find()), permanent: true);

    Get.put<AuthController>(
      AuthController(loadSession: Get.find(), signOut: Get.find()),
      permanent: true,
    );
    Get.put<PermissionsController>(
      PermissionsController(Get.find()),
      permanent: true,
    );
  }

  void _wireAuthRepository() {
    if (Env.useFakeData) {
      Get.put<AuthRepository>(FakeAuthRepository(), permanent: true);
      Get.put<DeviceRepository>(FakeDeviceRepository(), permanent: true);
      return;
    }

    final authInterceptor = AuthInterceptor(
      secureStore: Get.find<SecureStore>(),
      onUnauthorized: () => Get.find<AuthController>().onUnauthorized(),
    );
    Get.put<ApiClient>(
      ApiClient.configured(authInterceptor: authInterceptor),
      permanent: true,
    );
    Get.put<AuthRemoteDataSource>(
      AuthRemoteDataSource(Get.find()),
      permanent: true,
    );
    Get.put<AuthRepository>(
      AuthRepositoryImpl(remote: Get.find(), secureStore: Get.find()),
      permanent: true,
    );
    Get.put<DeviceRepository>(
      DeviceRepositoryImpl(DeviceRemoteDataSource(Get.find())),
      permanent: true,
    );
  }
}
