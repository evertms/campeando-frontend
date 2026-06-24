import '../../../../core/data/api_client.dart';
import '../models/confirmed_participant_model.dart';

abstract class ConfirmedParticipantsRemoteDatasource {
  Future<List<ConfirmedParticipantModel>> getConfirmedParticipants(
    String eventId,
  );
}

class ConfirmedParticipantsRemoteDatasourceImpl
    implements ConfirmedParticipantsRemoteDatasource {
  final ApiClient apiClient;

  ConfirmedParticipantsRemoteDatasourceImpl({required this.apiClient});

  @override
  Future<List<ConfirmedParticipantModel>> getConfirmedParticipants(
    String eventId,
  ) async {
    final response = await apiClient.get('/api/dashboard/participants/$eventId');
    final list = (response as List<dynamic>);
    return list
        .map(
          (e) =>
              ConfirmedParticipantModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }
}
