import 'flavor.dart';

/// Global access to the active [FlavorConfig]. Set exactly once, from the
/// flavor entrypoint, before `runApp`.
class Env {
  Env._();

  static const String apiPrefix = '/api/v1';

  static late FlavorConfig _config;
  static bool _initialised = false;

  static void init(FlavorConfig config) {
    _config = config;
    _initialised = true;
  }

  static FlavorConfig get config {
    assert(
      _initialised,
      'Env.init() must be called from the flavor entrypoint.',
    );
    return _config;
  }

  static bool get isInitialised => _initialised;

  static Flavor get flavor => config.flavor;
  static bool get isProd => _initialised && config.isProd;

  /// When true, feature bindings register the `FakeXRepository`s instead of the
  /// real HTTP-backed impls — so screens can be built and reviewed on a device
  /// before the backend is reachable. Never true in a prod build. Turn it off
  /// against a running API with `--dart-define=USE_FAKE_DATA=false`.
  static bool get useFakeData =>
      !isProd &&
      const bool.fromEnvironment('USE_FAKE_DATA', defaultValue: true);

  /// Fully-qualified API root, e.g. `https://api.bizops360.app/api/v1`.
  static String get apiRoot => '${config.apiBaseUrl}$apiPrefix';
}
