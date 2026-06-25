import 'package:flutter/material.dart';

import '../../../pending_applications/data/models/pending_application_model.dart';
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

  // --- Datos de la postulación (nombre + comprobante) ---
  PendingApplicationModel? _application;
  PendingApplicationModel? get application => _application;

  bool _isLoadingApplication = false;
  bool get isLoadingApplication => _isLoadingApplication;

  String? _loadError;
  String? get loadError => _loadError;

  /// Carga inicial del detalle. Si ya tenemos el modelo (navegación interna que
  /// pasó `extra`) lo usamos directo; si no (deep link), lo traemos por id.
  Future<void> loadApplication(
    String applicationId, {
    PendingApplicationModel? initial,
  }) async {
    if (initial != null) {
      _application = initial;
      _loadError = null;
      notifyListeners();
      return;
    }

    _isLoadingApplication = true;
    _loadError = null;
    notifyListeners();

    try {
      _application = await repository.getApplication(applicationId);
    } catch (e) {
      _loadError = 'No se pudo cargar la postulación: $e';
    } finally {
      _isLoadingApplication = false;
      notifyListeners();
    }
  }

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

  Future<void> shareApplication(
    String applicationId, {
    String? applicantName,
    String? tenantId,
  }) async {
    await shareService.shareApplicationLink(
      applicationId,
      applicantName: applicantName,
      tenantId: tenantId,
    );
  }
}
