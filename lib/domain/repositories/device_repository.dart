import '../../core/error/result.dart';

/// Registers this device's push token with the backend so the API can target
/// it (`POST /api/v1/devices`, `DELETE /api/v1/devices/{token}` — planned 7a).
abstract interface class DeviceRepository {
  Future<Result<void>> register({
    required String token,
    required String platform, // 'android' | 'ios'
  });

  Future<Result<void>> unregister(String token);
}
