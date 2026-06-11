import 'package:campeando_frontend/core/data/api_client.dart';
import 'package:campeando_frontend/features/events/data/models/event_detail_model.dart';
import 'package:campeando_frontend/features/events/data/models/event_summary_model.dart';

abstract class EventRemoteDatasource {
  Future<List<EventSummaryModel>> getAllEvents();
  Future<EventDetailModel> getEventById(String id);
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
}
