class EventSummaryModel {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;

  EventSummaryModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  factory EventSummaryModel.fromJson(Map<String, dynamic> json) {
    return EventSummaryModel(
      id: json['id'],
      name: json['name'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }
}
