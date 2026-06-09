import 'package:shared_preferences/shared_preferences.dart';

/// TODO: Encapsular todo acceso a persistencia local relacionado con Auth/Tenant.
class StorageService {
  StorageService(this._preferences);

  final SharedPreferences _preferences;

  static const String _tokenKey = 'campeando_auth_token';
  static const String _tenantKey = 'campeando_tenant_id';

  /// TODO: Retornar el JWT almacenado para sesiones autenticadas.
  Future<String?> getToken() async {
    throw UnimplementedError('TODO: implementar lectura de token desde SharedPreferences');
  }

  /// TODO: Persistir o limpiar el JWT.
  Future<void> setToken(String? token) async {
    throw UnimplementedError('TODO: implementar escritura de token en SharedPreferences');
  }

  /// TODO: Retornar el identificador del Tenant activo.
  Future<String?> getTenant() async {
    throw UnimplementedError('TODO: implementar lectura de tenant desde SharedPreferences');
  }

  /// TODO: Persistir o limpiar el identificador del Tenant.
  Future<void> setTenant(String? tenantId) async {
    throw UnimplementedError('TODO: implementar escritura de tenant en SharedPreferences');
  }
}