import 'package:flutter/material.dart';

import '../../domain/repositories/applications_repository.dart';
import '../../data/models/pending_application_model.dart';

class PendingApplicationsProvider extends ChangeNotifier {
  final ApplicationsRepository repository;

  PendingApplicationsProvider({required this.repository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<PendingApplicationModel> _applications = [];
  List<PendingApplicationModel> get applications => _applications;

  String? _error;
  String? get error => _error;

  Future<void> fetchPendingApplications(String tenantId, String eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _applications = await repository.getPendingApplications(
        tenantId,
        eventId,
      );
    } catch (e) {
      _error = 'Error al cargar las solicitudes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
