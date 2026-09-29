part of fixmate_app;

const _supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://qeguvopwnyyluynychtj.supabase.co',
);
const _supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'sb_publishable_R6Zv_H3C8xozJ2EAbqIRRQ_jyUnsOJ6',
);
const _configuredBackendUrl = String.fromEnvironment('BACKEND_URL');

// A local web build is served to the same computer as Django, so make the
// backend work without requiring a --dart-define on every `flutter run`.
// Release builds and mobile builds still require an explicit BACKEND_URL.
String get _backendUrl => _configuredBackendUrl.isNotEmpty
    ? _configuredBackendUrl
    : (kDebugMode && kIsWeb ? 'http://127.0.0.1:8000' : '');
const _primaryColor = Color(0xFF5B5CE2);
const _accentColor = Color(0xFFFF8A5B);
const _inkColor = Color(0xFF17182C);
const _mutedColor = Color(0xFF74758B);
const _surfaceColor = Color(0xFFFFFFFF);
const _backgroundColor = Color(0xFFF7F7FC);
const _providerColor = Color(0xFF0E9F8A);
const _navyColor = Color(0xFF24264F);
const _lavenderColor = Color(0xFF8B7CF6);
const _lineColor = Color(0xFFE7E7F2);
