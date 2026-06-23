import '../../domain/repositories/applications_repository.dart';
import '../datasources/applications_remote_datasource.dart';
import '../models/pending_application_model.dart';

class ApplicationsRepositoryImpl implements ApplicationsRepository {
  final ApplicationsRemoteDatasource remoteDatasource;

  ApplicationsRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<PendingApplicationModel>> getPendingApplications(
    String tenantId,
    String eventId,
  ) async {
    return await remoteDatasource.getPendingApplications(tenantId, eventId);
  }
}
