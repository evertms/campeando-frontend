import '../../domain/repositories/confirmed_participants_repository.dart';
import '../datasources/confirmed_participants_remote_datasource.dart';
import '../models/confirmed_participant_model.dart';

class ConfirmedParticipantsRepositoryImpl
    implements ConfirmedParticipantsRepository {
  final ConfirmedParticipantsRemoteDatasource remoteDatasource;

  ConfirmedParticipantsRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<ConfirmedParticipantModel>> getConfirmedParticipants(
    String eventId,
  ) {
    return remoteDatasource.getConfirmedParticipants(eventId);
  }
}
