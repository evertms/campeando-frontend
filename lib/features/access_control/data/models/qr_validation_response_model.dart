class QrValidationResponseModel {
  final bool success;
  final String message;

  QrValidationResponseModel({required this.success, required this.message});

  factory QrValidationResponseModel.fromJson(Map<String, dynamic> json) {
    return QrValidationResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
