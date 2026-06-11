class EventDetailModel {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final int maxCapacity;

  EventDetailModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.maxCapacity,
  });

  factory EventDetailModel.fromJson(Map<String, dynamic> json) {
    return EventDetailModel(
      id: json['id'],
      name: json['name'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      maxCapacity: json['maxCapacity'],
    );
  }
}
