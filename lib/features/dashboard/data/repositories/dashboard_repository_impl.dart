import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../models/event_metrics_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDatasource remoteDatasource;

  DashboardRepositoryImpl({required this.remoteDatasource});

  @override
  Future<EventMetricsModel> getEventMetrics(String eventId) {
    return remoteDatasource.getEventMetrics(eventId);
  }
}
