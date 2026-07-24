/// Backend base URL.
///
/// Override at build/run time with:
///   flutter run --dart-define=API_BASE_URL=https://your-backend.example.com/api/v1
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000/api/v1',
);

/// How often the dashboard polls the backend for fresh figures.
///
/// This is plain HTTP polling, not a push/WebSocket feed - labelled as such
/// in the UI so nobody mistakes it for lower latency than it actually has.
const Duration dashboardRefreshInterval = Duration(seconds: 30);
