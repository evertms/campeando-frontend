/// Host base del backend. Configurable en build/run time con:
///   `flutter run --dart-define=BASE_URL=http://IP_LAN:5206`
/// Por defecto apunta a localhost (web/desktop/dev local). Para emulador Android
/// usar `http://10.0.2.2:5206` y para dispositivo físico la IP LAN de la PC.
const String baseUrl = String.fromEnvironment(
  'BASE_URL',
  defaultValue: 'http://localhost:5206',
);
