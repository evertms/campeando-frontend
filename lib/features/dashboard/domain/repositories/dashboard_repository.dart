import '../../data/models/event_metrics_model.dart';

abstract class DashboardRepository {
  Future<EventMetricsModel> getEventMetrics(String eventId);
}
