/// Backend API manzili. Ishlab chiqarishda `--dart-define=API_BASE_URL=...` orqali
/// almashtiring: flutter run --dart-define=API_BASE_URL=https://api.uzumtezkor.uz/api/v1
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1', // Android emulyator uchun localhost
  );

  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );
}
