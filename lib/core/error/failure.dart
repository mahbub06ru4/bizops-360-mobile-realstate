import 'package:equatable/equatable.dart';

/// A user-facing outcome of a failed operation. The data layer maps every
/// exception into one of these; controllers show [message] and never see a
/// raw [DioException].
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// No usable connection, DNS failure, or a request/response timeout.
class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'No connection. Check your network and try again.',
  ]);
}

/// The server answered with a 5xx or an otherwise unexpected shape.
class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Something went wrong on our side. Try again shortly.',
  ]);
}

/// The token is missing, expired or was revoked — the session is over.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'Your session has ended. Sign in again.',
  ]);
}

/// The caller lacks permission for this action (403).
class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = "You don't have access to this."]);
}

/// A 404 for a resource the caller expected to exist.
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'That item no longer exists.']);
}

/// A 422 with per-field messages from a Laravel form request.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, this.errors);

  /// field name -> list of messages.
  final Map<String, List<String>> errors;

  /// The first message for [field], if the server flagged it.
  String? forField(String field) => errors[field]?.firstOrNull;

  @override
  List<Object?> get props => [message, errors];
}

/// Anything the layers above couldn't classify.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unexpected error. Try again.']);
}
