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

  AuthProvider({
    required this._authRepository,
    required this._storageService,
  }) {
    _init();
  }

  Future<void> _init() async {
    _token = await _storageService.getToken();
    _organizationId = await _storageService.getTenant();

    if (_token != null && !JwtDecoder.isExpired(_token!)) {
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
      _token = null;
      await _storageService.setToken(null);
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      _token = await _authRepository.login(email, password);
      await _storageService.setToken(_token);

      // Extract organizationId (tenant_id) from JWT if available
      final decodedToken = JwtDecoder.decode(_token!);
      _organizationId = decodedToken['tenant_id'] as String?;
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
    _organizationId = id;
    await _storageService.setTenant(id);
    notifyListeners();
  }
}
