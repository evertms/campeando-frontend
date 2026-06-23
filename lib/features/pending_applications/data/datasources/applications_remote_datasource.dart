import '../../../../core/data/api_client.dart';
import '../models/pending_application_model.dart';

abstract class ApplicationsRemoteDatasource {
  Future<List<PendingApplicationModel>> getPendingApplications(
    String tenantId,
    String eventId,
  );
}

class ApplicationsRemoteDatasourceImpl implements ApplicationsRemoteDatasource {
  final ApiClient apiClient;

  ApplicationsRemoteDatasourceImpl({required this.apiClient});

  @override
  Future<List<PendingApplicationModel>> getPendingApplications(
    String tenantId,
    String eventId,
  ) async {
    final response = await apiClient.get(
      '/api/applications/pending?tenantId=$tenantId&eventId=$eventId',
    );
    final List<dynamic> data = response['applications'] as List<dynamic>;
    return data
        .map(
          (json) =>
              PendingApplicationModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }
}
