/// API base URL configuration.
///
/// Switch environments via `--dart-define=API_BASE_URL=...` or edit defaults below.
/// Android emulator localhost: http://10.0.2.2:8000/api
/// Production: set your Railway Laravel URL when deploying.
abstract final class ApiConfig {
  static const String _defaultDev = 'http://10.0.2.2:8000/api';

  /// Override at build/run time: `--dart-define=API_BASE_URL=https://your-app.railway.app/api`
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultDev,
  );

  static const Duration timeout = Duration(seconds: 45);
}
