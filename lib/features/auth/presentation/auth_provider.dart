import 'package:campeando_frontend/core/data/storage_service.dart';
import 'package:campeando_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

enum AuthStatus { initial, authenticated, unauthenticated, authenticating }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final StorageService _storageService;

  AuthStatus _status = AuthStatus.initial;
  String? _token;
  String? _organizationId;

  AuthStatus get status => _status;
  String? get token => _token;
  String? get organizationId => _organizationId;

  AuthProvider({required this._authRepository, required this._storageService}) {
    _init();
  }

  Future<void> _init() async {
    try {
      _token = await _storageService.getToken();
      final rawOrgId = await _storageService.getTenant();
      _organizationId = _cleanId(rawOrgId);

      if (_token != null && !JwtDecoder.isExpired(_token!)) {
        _status = AuthStatus.authenticated;
      } else {
        await _resetSession();
      }
    } catch (_) {
      // Un token corrupto, malformado o sin campo `exp` hace que
      // JwtDecoder lance una excepción. Si la dejamos escapar, el estado
      // se queda en AuthStatus.initial y la app queda en "cargando" para
      // siempre al reabrir. Lo tratamos como sesión inválida.
      await _resetSession();
    } finally {
      // Garantiza que SIEMPRE salgamos de AuthStatus.initial y que el
      // router (refreshListenable) reevalúe el redirect.
      notifyListeners();
    }
  }

  Future<void> _resetSession() async {
    _status = AuthStatus.unauthenticated;
    _token = null;
    _organizationId = null;
    await _storageService.clear();
  }

  String? _cleanId(String? id) {
    if (id == null) return null;
    return id.replaceAll('"', '').trim();
  }

  Future<void> login(String email, String password) async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      _token = await _authRepository.login(email, password);
      await _storageService.setToken(_token);

      // Extract organizationId (tenant_id) from JWT if available
      final decodedToken = JwtDecoder.decode(_token!);
      final rawOrgId = decodedToken['tenant_id'] as String?;
      _organizationId = _cleanId(rawOrgId);

      if (_organizationId != null) {
        await _storageService.setTenant(_organizationId);
      }

      _status = AuthStatus.authenticated;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> register(String email, String password) async {
    await _authRepository.register(email, password);
  }

  Future<void> logout() async {
    await _authRepository.logout();
    await _storageService.clear();
    _token = null;
    _organizationId = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> selectOrganization(String id) async {
    final cleanedId = _cleanId(id);
    _organizationId = cleanedId;
    await _storageService.setTenant(cleanedId);
    notifyListeners();
  }
}
