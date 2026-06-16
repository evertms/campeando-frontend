class EventSummaryModel {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String? organizationId;

  EventSummaryModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.organizationId,
  });

  factory EventSummaryModel.fromJson(Map<String, dynamic> json) {
    return EventSummaryModel(
      id: (json['id'] ?? '') as String,
      name: (json['name'] ?? 'Sin nombre') as String,
      startDate: DateTime.parse((json['startDate'] ?? DateTime.now().toIso8601String()) as String),
      endDate: DateTime.parse((json['endDate'] ?? DateTime.now().toIso8601String()) as String),
      organizationId: (json['organizationId'] ?? json['tenantId'] ?? json['tenant_id']) as String?,
    );
  }
}
