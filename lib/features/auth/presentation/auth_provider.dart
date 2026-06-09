import 'package:flutter/foundation.dart';

import '../domain/account_entity.dart';

/// TODO: Centralizar el estado de autenticación usando ChangeNotifier.
enum AuthStatus {
  initial,
  loading,
  authenticated,
  error,
}

/// TODO: Exponer el estado de Auth para screens y widgets de la feature.
class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  AccountEntity? _account;

  AuthStatus get status => _status;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get errorMessage => _errorMessage;
  AccountEntity? get account => _account;

  /// TODO: Marcar el flujo como cargando mientras se valida sesión o credenciales.
  void setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  /// TODO: Guardar el usuario autenticado y notificar a la UI.
  void setAuthenticated(AccountEntity account) {
    _status = AuthStatus.authenticated;
    _account = account;
    _errorMessage = null;
    notifyListeners();
  }

  /// TODO: Registrar el error del flujo de autenticación.
  void setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  /// TODO: Limpiar el estado al cerrar sesión o reiniciar la sesión.
  void reset() {
    _status = AuthStatus.initial;
    _errorMessage = null;
    _account = null;
    notifyListeners();
  }
}