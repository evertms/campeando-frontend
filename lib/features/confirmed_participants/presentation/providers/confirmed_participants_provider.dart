import 'package:flutter/material.dart';

import '../../data/models/confirmed_participant_model.dart';
import '../../domain/repositories/confirmed_participants_repository.dart';

class ConfirmedParticipantsProvider extends ChangeNotifier {
  final ConfirmedParticipantsRepository repository;

  ConfirmedParticipantsProvider({required this.repository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ConfirmedParticipantModel> _participants = [];
  List<ConfirmedParticipantModel> get participants => _participants;

  String? _error;
  String? get error => _error;

  Future<void> loadParticipants(String eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _participants = await repository.getConfirmedParticipants(eventId);
    } catch (e) {
      _error = 'Error al cargar los participantes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
