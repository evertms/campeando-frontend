import '../data/models/pending_application_model.dart';

abstract class ApplicationsRepository {
  Future<List<PendingApplicationModel>> getPendingApplications(
    String tenantId,
    String eventId,
  );
}
