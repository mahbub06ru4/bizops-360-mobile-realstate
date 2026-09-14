import 'package:dio/dio.dart';

import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../core/network/dio_failure_mapper.dart';
import '../../core/utils/logger.dart';
import '../../domain/repositories/device_repository.dart';
import '../datasources/device_remote_datasource.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  DeviceRepositoryImpl(this._remote);

  final DeviceRemoteDataSource _remote;

  @override
  Future<Result<void>> register({
    required String token,
    required String platform,
  }) => _guard(() => _remote.register(token: token, platform: platform));

  @override
  Future<Result<void>> unregister(String token) =>
      _guard(() => _remote.unregister(token));

  Future<Result<void>> _guard(Future<void> Function() run) async {
    try {
      await run();
      return const Result.ok(null);
    } on DioException catch (e) {
      final failure = mapDioException(e);
      // The `/devices` endpoint is 7a backend work — a 404 just means "not live
      // yet", not a real error. Don't surface it.
      if (failure is NotFoundFailure) {
        AppLog.d('device endpoint not available yet', name: 'push');
        return const Result.ok(null);
      }
      return Result.err(failure);
    } on Object {
      return const Result.err(UnknownFailure());
    }
  }
}
