import 'package:bizops360_mobile/core/error/failure.dart';
import 'package:bizops360_mobile/core/network/dio_failure_mapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _badResponse(int status, Object? body) {
  final options = RequestOptions(path: '/auth/me');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: options,
      statusCode: status,
      data: body,
    ),
  );
}

void main() {
  test('timeout maps to NetworkFailure', () {
    final f = mapDioException(
      DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.connectionTimeout,
      ),
    );
    expect(f, isA<NetworkFailure>());
  });

  test('401 maps to UnauthorizedFailure', () {
    final f = mapDioException(
      _badResponse(401, {'message': 'Unauthenticated.'}),
    );
    expect(f, isA<UnauthorizedFailure>());
  });

  test('403 maps to ForbiddenFailure', () {
    expect(mapDioException(_badResponse(403, null)), isA<ForbiddenFailure>());
  });

  test('422 maps to ValidationFailure with per-field errors', () {
    final f = mapDioException(
      _badResponse(422, {
        'message': 'The given data was invalid.',
        'errors': {
          'email': ['These credentials do not match our records.'],
        },
      }),
    );

    expect(f, isA<ValidationFailure>());
    expect(
      (f as ValidationFailure).forField('email'),
      'These credentials do not match our records.',
    );
  });

  test('500 maps to ServerFailure', () {
    expect(mapDioException(_badResponse(500, null)), isA<ServerFailure>());
  });
}
