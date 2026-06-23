import 'package:campeando_frontend/features/events/data/models/event_detail_model.dart';
import 'package:campeando_frontend/features/events/data/models/event_summary_model.dart';

abstract class EventRepository {
  Future<List<EventSummaryModel>> getAllEvents();
  Future<EventDetailModel> getEventById(String id);
  Future<void> createEvent({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required int maxCapacity,
    required String organizationId,
    String? coverImageBase64,
    String? paymentQrBase64,
  });
}
