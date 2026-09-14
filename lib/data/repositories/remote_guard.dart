import 'package:dio/dio.dart';

import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../core/network/dio_failure_mapper.dart';

/// Runs [request], returning `Result.ok` with its value, or `Result.err` with a
/// typed [Failure] — a [DioException] via [mapDioException], anything else as
/// [UnknownFailure]. The single place the HTTP-backed repositories catch.
Future<Result<T>> guardRequest<T>(Future<T> Function() request) async {
  try {
    return Result.ok(await request());
  } on DioException catch (e) {
    return Result.err(mapDioException(e));
  } on Object {
    return const Result.err(UnknownFailure());
  }
}
