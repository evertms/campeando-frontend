import '../../data/models/confirmed_participant_model.dart';

abstract class ConfirmedParticipantsRepository {
  Future<List<ConfirmedParticipantModel>> getConfirmedParticipants(
    String eventId,
  );
}
