import 'package:flutter/material.dart';

import '../../data/models/event_metrics_model.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository repository;

  DashboardProvider({required this.repository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  EventMetricsModel? _metrics;
  EventMetricsModel? get metrics => _metrics;

  String? _error;
  String? get error => _error;

  Future<void> loadMetrics(String eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _metrics = await repository.getEventMetrics(eventId);
    } catch (e) {
      _error = 'Error al cargar las métricas: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
