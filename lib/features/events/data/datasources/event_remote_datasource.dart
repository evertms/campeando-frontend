import 'package:campeando_frontend/core/data/api_client.dart';
import 'package:campeando_frontend/features/events/data/models/event_detail_model.dart';
import 'package:campeando_frontend/features/events/data/models/event_summary_model.dart';

abstract class EventRemoteDatasource {
  Future<List<EventSummaryModel>> getAllEvents();
  Future<EventDetailModel> getEventById(String id);
  Future<void> createEvent({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required int maxCapacity,
    required String organizationId,
  });
}

class EventRemoteDatasourceImpl implements EventRemoteDatasource {
  final ApiClient apiClient;

  EventRemoteDatasourceImpl({required this.apiClient});

  @override
  Future<List<EventSummaryModel>> getAllEvents() async {
    final response = await apiClient.get('/api/events');
    return (response as List)
        .map((eventJson) => EventSummaryModel.fromJson(eventJson))
        .toList();
  }

  @override
  Future<EventDetailModel> getEventById(String id) async {
    final response = await apiClient.get('/api/events/$id');
    return EventDetailModel.fromJson(response);
  }

  @override
  Future<void> createEvent({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required int maxCapacity,
    required String organizationId,
  }) async {
    await apiClient.post(
      '/api/events',
      body: {
        'name': name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'maxCapacity': maxCapacity,
        'organizationId': organizationId,
      },
    );
  }
}
