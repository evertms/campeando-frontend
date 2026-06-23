class PendingApplicationModel {
  final String id;
  final String applicantName;
  final String paymentStatus;
  final DateTime appliedAt;

  PendingApplicationModel({
    required this.id,
    required this.applicantName,
    required this.paymentStatus,
    required this.appliedAt,
  });

  factory PendingApplicationModel.fromJson(Map<String, dynamic> json) {
    return PendingApplicationModel(
      id: json['id'] as String,
      applicantName: json['applicantName'] as String,
      paymentStatus: json['paymentStatus'] as String,
      appliedAt: DateTime.parse(json['appliedAt'] as String),
    );
  }
}
