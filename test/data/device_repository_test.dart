import 'package:bizops360_mobile/core/error/failure.dart';
import 'package:bizops360_mobile/data/datasources/device_remote_datasource.dart';
import 'package:bizops360_mobile/data/repositories/device_repository_impl.dart';
import 'package:bizops360_mobile/data/repositories/fake_device_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeClient implements DeviceRemoteDataSource {
  _FakeClient(this._throw);
  final Object? _throw;
  @override
  Future<void> register({
    required String token,
    required String platform,
  }) async {
    final e = _throw;
    if (e != null) throw e;
  }

  @override
  Future<void> unregister(String token) async {
    final e = _throw;
    if (e != null) throw e;
  }
}

DioException _dio(int status) => DioException(
  requestOptions: RequestOptions(path: '/devices'),
  type: DioExceptionType.badResponse,
  response: Response<dynamic>(
    requestOptions: RequestOptions(path: '/devices'),
    statusCode: status,
  ),
);

void main() {
  test('fake device repo is a no-op that succeeds', () async {
    final r = FakeDeviceRepository();
    expect((await r.register(token: 'abc', platform: 'android')).isOk, isTrue);
    expect((await r.unregister('abc')).isOk, isTrue);
  });

  test('impl swallows a 404 (endpoint not live yet)', () async {
    final r = DeviceRepositoryImpl(_FakeClient(_dio(404)));
    expect((await r.register(token: 't', platform: 'ios')).isOk, isTrue);
  });

  test('impl surfaces a real failure (500)', () async {
    final r = DeviceRepositoryImpl(_FakeClient(_dio(500)));
    final result = await r.register(token: 't', platform: 'ios');
    expect(result.failureOrNull, isA<ServerFailure>());
  });
}
