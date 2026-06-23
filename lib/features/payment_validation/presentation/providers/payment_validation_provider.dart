import 'package:flutter/material.dart';

import '../../application/share_deep_link_service.dart';
import '../../domain/repositories/payment_validation_repository.dart';

class PaymentValidationProvider extends ChangeNotifier {
  final PaymentValidationRepository repository;
  final ShareDeepLinkService shareService;

  PaymentValidationProvider({
    required this.repository,
    required this.shareService,
  });

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  String? _receiptUrl;
  String? get receiptUrl => _receiptUrl;

  String? _error;
  String? get error => _error;

  Future<void> uploadReceipt(String applicationId, String base64Image) async {
    _isUploading = true;
    _error = null;
    notifyListeners();

    try {
      final url = await repository.uploadReceipt(applicationId, base64Image);
      _receiptUrl = url;
    } catch (e) {
      _error = 'Error al subir el comprobante: $e';
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> shareApplication(String applicationId) async {
    await shareService.shareApplicationLink(applicationId);
  }
}
