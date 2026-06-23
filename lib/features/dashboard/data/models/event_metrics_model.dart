class EventMetricsModel {
  final int totalCapacity;
  final int checkedInCount;
  final int rationsConsumed;

  EventMetricsModel({
    required this.totalCapacity,
    required this.checkedInCount,
    required this.rationsConsumed,
  });

  factory EventMetricsModel.fromJson(Map<String, dynamic> json) {
    return EventMetricsModel(
      totalCapacity: (json['totalCapacity'] as num?)?.toInt() ?? 0,
      checkedInCount: (json['checkedInCount'] as num?)?.toInt() ?? 0,
      rationsConsumed: (json['rationsConsumed'] as num?)?.toInt() ?? 0,
    );
  }
}
