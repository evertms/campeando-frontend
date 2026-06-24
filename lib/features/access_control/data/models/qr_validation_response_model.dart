class QrValidationResponseModel {
  final bool success;
  final String message;
  final String? participantId;
  final String? participantName;
  final int rationsConsumed;

  QrValidationResponseModel({
    required this.success,
    required this.message,
    this.participantId,
    this.participantName,
    this.rationsConsumed = 0,
  });

  factory QrValidationResponseModel.fromJson(Map<String, dynamic> json) {
    return QrValidationResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      participantId: json['participantId']?.toString(),
      participantName: json['participantName']?.toString(),
      rationsConsumed: (json['rationsConsumed'] as num?)?.toInt() ?? 0,
    );
  }
}
