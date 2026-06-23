import 'package:flutter/material.dart';

import '../../application/share_deep_link_service.dart';
import '../../domain/repositories/payment_validation_repository.dart';

enum ApplicationDecision { none, accepted, rejected }

class PaymentValidationProvider extends ChangeNotifier {
  final PaymentValidationRepository repository;
  final ShareDeepLinkService shareService;

  PaymentValidationProvider({
    required this.repository,
    required this.shareService,
  });

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  String? _error;
  String? get error => _error;

  ApplicationDecision _decision = ApplicationDecision.none;
  ApplicationDecision get decision => _decision;

  Future<bool> acceptApplication(String orderId) =>
      _decide(orderId, accept: true);

  Future<bool> rejectApplication(String orderId) =>
      _decide(orderId, accept: false);

  Future<bool> _decide(String orderId, {required bool accept}) async {
    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      if (accept) {
        await repository.acceptApplication(orderId);
      } else {
        await repository.rejectApplication(orderId);
      }
      _decision = accept
          ? ApplicationDecision.accepted
          : ApplicationDecision.rejected;
      return true;
    } catch (e) {
      _error = 'No se pudo actualizar la solicitud: $e';
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> shareApplication(String applicationId) async {
    await shareService.shareApplicationLink(applicationId);
  }
}
