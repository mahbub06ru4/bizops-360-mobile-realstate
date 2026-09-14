import '../error/failure.dart';

/// The state of an async load a controller exposes to its screen. Pair with
/// `AsyncView` in the presentation layer for consistent loading / empty /
/// error / data rendering.
sealed class AsyncValue<T> {
  const AsyncValue();

  const factory AsyncValue.loading() = AsyncLoading<T>;
  const factory AsyncValue.data(T value) = AsyncData<T>;
  const factory AsyncValue.error(Failure failure) = AsyncError<T>;

  T? get valueOrNull => switch (this) {
    AsyncData<T>(:final value) => value,
    _ => null,
  };

  R when<R>({
    required R Function() loading,
    required R Function(T value) data,
    required R Function(Failure failure) error,
  }) => switch (this) {
    AsyncLoading<T>() => loading(),
    AsyncData<T>(:final value) => data(value),
    AsyncError<T>(:final failure) => error(failure),
  };
}

class AsyncLoading<T> extends AsyncValue<T> {
  const AsyncLoading();
}

class AsyncData<T> extends AsyncValue<T> {
  const AsyncData(this.value);
  final T value;
}

class AsyncError<T> extends AsyncValue<T> {
  const AsyncError(this.failure);
  final Failure failure;
}
