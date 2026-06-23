import '../../../../core/data/api_client.dart';
import '../models/event_metrics_model.dart';

abstract class DashboardRemoteDatasource {
  Future<EventMetricsModel> getEventMetrics(String eventId);
}

class DashboardRemoteDatasourceImpl implements DashboardRemoteDatasource {
  final ApiClient apiClient;

  DashboardRemoteDatasourceImpl({required this.apiClient});

  @override
  Future<EventMetricsModel> getEventMetrics(String eventId) async {
    final response = await apiClient.get('/api/dashboard/metrics/$eventId');
    return EventMetricsModel.fromJson(response as Map<String, dynamic>);
  }
}
