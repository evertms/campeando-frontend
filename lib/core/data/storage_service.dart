import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences _preferences;

  StorageService(this._preferences);

  static const String _tokenKey = 'campeando_auth_token';
  static const String _tenantKey = 'campeando_tenant_id';

  Future<String?> getToken() async {
    return _preferences.getString(_tokenKey);
  }

  Future<void> setToken(String? token) async {
    if (token == null) {
      await _preferences.remove(_tokenKey);
    } else {
      await _preferences.setString(_tokenKey, token);
    }
  }

  Future<String?> getTenant() async {
    return _preferences.getString(_tenantKey);
  }

  Future<void> setTenant(String? tenantId) async {
    if (tenantId == null) {
      await _preferences.remove(_tenantKey);
    } else {
      await _preferences.setString(_tenantKey, tenantId);
    }
  }

  Future<void> clear() async {
    await _preferences.remove(_tokenKey);
    await _preferences.remove(_tenantKey);
  }
}
