import 'package:flutter/material.dart';

import '../../domain/repositories/access_control_repository.dart';

class AccessControlProvider extends ChangeNotifier {
  final AccessControlRepository repository;

  AccessControlProvider({required this.repository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String? _successMessage;
  String? get successMessage => _successMessage;

  Future<void> validateQr(String payload) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await repository.validateQr(payload);
      if (response.success) {
        _successMessage =
            '${response.message} (Raciones consumidas: ${response.rationsConsumed})';
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Ocurrió un error al validar el QR: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}
