import 'package:get/get.dart';

import '../../core/config/env.dart';
import '../../core/network/api_client.dart';

/// Registers the real HTTP-backed repository, or the in-memory fake when
/// `Env.useFakeData` is on, under [T] — once. Feature bindings call this instead
/// of hand-rolling the branch. [real] is only invoked when the API is in play,
/// so it may safely `Get.find<ApiClient>()` (permanent in `AppBinding` then).
void registerRepo<T>(T Function(ApiClient client) real, T Function() fake) {
  if (Get.isRegistered<T>()) return;
  Get.put<T>(
    Env.useFakeData ? fake() : real(Get.find<ApiClient>()),
    permanent: true,
  );
}
