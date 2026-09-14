/// Build flavor. Selected by the entrypoint (`main_dev.dart` / `main_prod.dart`)
/// and read everywhere through [Env].
enum Flavor { dev, staging, prod }

class FlavorConfig {
  const FlavorConfig({
    required this.flavor,
    required this.apiBaseUrl,
    required this.name,
  });

  final Flavor flavor;

  /// Origin only, no trailing slash. The `/api/v1` prefix lives in [Env.apiPrefix].
  final String apiBaseUrl;

  /// Shown in the app bar / about screen for non-prod builds.
  final String name;

  bool get isProd => flavor == Flavor.prod;
}
