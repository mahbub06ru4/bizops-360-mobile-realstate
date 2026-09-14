import '../../core/error/result.dart';
import '../../core/utils/logger.dart';
import '../../domain/repositories/device_repository.dart';

/// No-op device registration for `Env.useFakeData` — just logs.
class FakeDeviceRepository implements DeviceRepository {
  @override
  Future<Result<void>> register({
    required String token,
    required String platform,
  }) async {
    AppLog.d(
      'fake: register device ($platform) ${_short(token)}',
      name: 'push',
    );
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> unregister(String token) async {
    AppLog.d('fake: unregister device ${_short(token)}', name: 'push');
    return const Result.ok(null);
  }

  String _short(String t) => t.length > 12 ? '${t.substring(0, 12)}…' : t;
}
