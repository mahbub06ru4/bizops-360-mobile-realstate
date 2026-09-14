import 'package:dio/dio.dart';

import '../error/failure.dart';

/// Turns a [DioException] into a typed [Failure]. This is the only place that
/// knows about HTTP status codes and the Laravel error envelope.
Failure mapDioException(DioException e) {
  return switch (e.type) {
    DioExceptionType.badResponse => _fromResponse(e.response),
    DioExceptionType.cancel => const UnknownFailure('Request cancelled.'),
    DioExceptionType.badCertificate => const NetworkFailure(
      'Could not verify a secure connection.',
    ),
    _ => const NetworkFailure(),
  };
}

Failure _fromResponse(Response<dynamic>? response) {
  final status = response?.statusCode ?? 0;
  final body = response?.data;
  final message = _messageFrom(body);

  return switch (status) {
    401 => const UnauthorizedFailure(),
    403 => ForbiddenFailure(message ?? "You don't have access to this."),
    404 => NotFoundFailure(message ?? 'That item no longer exists.'),
    422 => ValidationFailure(
      message ?? 'Please check the highlighted fields.',
      _errorsFrom(body),
    ),
    >= 500 => const ServerFailure(),
    _ => ServerFailure(message ?? 'Request failed ($status).'),
  };
}

String? _messageFrom(dynamic body) {
  if (body is Map && body['message'] is String) {
    final msg = body['message'] as String;
    return msg.isEmpty ? null : msg;
  }
  return null;
}

Map<String, List<String>> _errorsFrom(dynamic body) {
  if (body is! Map || body['errors'] is! Map) return const {};
  final raw = body['errors'] as Map;
  return raw.map(
    (key, value) => MapEntry(
      key.toString(),
      (value is List ? value : [value]).map((e) => e.toString()).toList(),
    ),
  );
}
