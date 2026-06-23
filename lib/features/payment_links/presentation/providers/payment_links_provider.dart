import 'package:flutter/material.dart';

import '../../application/payment_link_sharing_service.dart';
import '../../domain/repositories/payment_links_repository.dart';

class PaymentLinksProvider extends ChangeNotifier {
  final PaymentLinksRepository repository;
  final PaymentLinkSharingService sharingService;

  PaymentLinksProvider({
    required this.repository,
    required this.sharingService,
  });

  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;

  String? _generatedLink;
  String? get generatedLink => _generatedLink;

  String? _error;
  String? get error => _error;

  Future<void> generateAndShareLink(
    String applicationId,
    String applicantName,
  ) async {
    _isGenerating = true;
    _error = null;
    notifyListeners();

    try {
      _generatedLink = await repository.generatePaymentLink(applicationId);
      await sharingService.shareLink(_generatedLink!, applicantName);
    } catch (e) {
      _error = 'Error al generar enlace: $e';
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }
}
