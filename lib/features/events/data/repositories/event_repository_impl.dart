import 'package:campeando_frontend/features/events/data/datasources/event_remote_datasource.dart';
import 'package:campeando_frontend/features/events/data/models/event_detail_model.dart';
import 'package:campeando_frontend/features/events/data/models/event_summary_model.dart';
import 'package:campeando_frontend/features/events/domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDatasource remoteDatasource;

  EventRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<EventSummaryModel>> getAllEvents() {
    return remoteDatasource.getAllEvents();
  }

  @override
  Future<EventDetailModel> getEventById(String id) {
    return remoteDatasource.getEventById(id);
  }

  @override
  Future<void> createEvent({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required int maxCapacity,
    required String organizationId,
    String? coverImageBase64,
    String? paymentQrBase64,
  }) {
    return remoteDatasource.createEvent(
      name: name,
      startDate: startDate,
      endDate: endDate,
      maxCapacity: maxCapacity,
      organizationId: organizationId,
      coverImageBase64: coverImageBase64,
      paymentQrBase64: paymentQrBase64,
    );
  }
}
