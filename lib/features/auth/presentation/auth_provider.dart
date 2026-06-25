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

  AuthProvider({required this._authRepository, required this._storageService});

  /// Resuelve la sesión al arrancar la app. Se invoca desde `main()` con
  /// `await` ANTES de construir la UI, de modo que el router nunca se monta
  /// en `AuthStatus.initial` (causa del spinner infinito al reabrir).
  Future<void> initialize() async {
    try {
      _token = await _storageService.getToken();
      final rawOrgId = await _storageService.getTenant();
      _organizationId = _cleanId(rawOrgId);

      if (_token != null && !JwtDecoder.isExpired(_token!)) {
        _status = AuthStatus.authenticated;
      } else if (await _attemptRefresh()) {
        // El access token venció pero pudimos renovarlo con el refresh token:
        // la sesión persiste sin pedir login de nuevo.
        _status = AuthStatus.authenticated;
      } else {
        await _resetSession();
      }
    } catch (_) {
      // Un token corrupto/malformado hace que JwtDecoder lance. Si lo dejamos
      // escapar, el estado queda en AuthStatus.initial y la app se queda
      // "cargando" para siempre. Lo tratamos como sesión inválida.
      await _resetSession();
    } finally {
      // Garantiza que SIEMPRE salgamos de AuthStatus.initial.
      if (_status == AuthStatus.initial) {
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    }
  }

  /// Intenta renovar el access token con el refresh token almacenado.
  /// Devuelve `true` si lo logró (token nuevo persistido), `false` si no.
  /// Acota la espera de red para no demorar el arranque indefinidamente.
  Future<bool> _attemptRefresh() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final tokens = await _authRepository
          .refresh(refreshToken)
          .timeout(const Duration(seconds: 8));

      _token = tokens.accessToken;
      await _storageService.setToken(_token);
      if (tokens.refreshToken != null) {
        await _storageService.setRefreshToken(tokens.refreshToken);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Hook que [ApiClient] invoca ante un 401: intenta renovar la sesión; si no
  /// puede, cierra la sesión para que el router lleve a login.
  Future<bool> handleUnauthorized() async {
    final renewed = await _attemptRefresh();
    if (!renewed) {
      await _resetSession();
      notifyListeners();
    }
    return renewed;
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
      final tokens = await _authRepository.login(email, password);
      _token = tokens.accessToken;
      await _storageService.setToken(_token);
      await _storageService.setRefreshToken(tokens.refreshToken);

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
