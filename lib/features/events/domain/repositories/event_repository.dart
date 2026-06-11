import 'package:campeando_frontend/features/events/data/models/event_detail_model.dart';
import 'package:campeando_frontend/features/events/data/models/event_summary_model.dart';

abstract class EventRepository {
  Future<List<EventSummaryModel>> getAllEvents();
  Future<EventDetailModel> getEventById(String id);
}
