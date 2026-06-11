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
}
