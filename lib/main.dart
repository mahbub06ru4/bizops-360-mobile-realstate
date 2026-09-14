import 'bootstrap.dart';
import 'core/config/flavor.dart';

/// Default entrypoint (`flutter run`) → dev flavor.
/// Override the API origin at build time with:
///   --dart-define=API_BASE_URL=https://staging.bizops360.example
void main() {
  const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
        'http://10.0.2.2', // Android emulator → host machine's localhost
  );

  bootstrap(
    const FlavorConfig(flavor: Flavor.dev, apiBaseUrl: baseUrl, name: 'dev'),
  );
}
