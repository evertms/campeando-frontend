class ConfirmedParticipantModel {
  final String participantId;
  final String fullName;
  final int rationsConsumed;

  ConfirmedParticipantModel({
    required this.participantId,
    required this.fullName,
    required this.rationsConsumed,
  });

  factory ConfirmedParticipantModel.fromJson(Map<String, dynamic> json) {
    return ConfirmedParticipantModel(
      participantId: json['participantId']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      rationsConsumed: (json['rationsConsumed'] as num?)?.toInt() ?? 0,
    );
  }
}
