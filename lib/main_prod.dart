import 'bootstrap.dart';
import 'core/config/flavor.dart';

/// Production entrypoint:
///   flutter run --release -t lib/main_prod.dart --dart-define=API_BASE_URL=https://api.bizops360.app
void main() {
  const baseUrl = String.fromEnvironment('API_BASE_URL');
  assert(
    baseUrl.isNotEmpty,
    'Pass --dart-define=API_BASE_URL for the prod build.',
  );

  bootstrap(
    const FlavorConfig(flavor: Flavor.prod, apiBaseUrl: baseUrl, name: 'prod'),
  );
}
