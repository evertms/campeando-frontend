class EventMetricsModel {
  final int totalCapacity;
  final int checkedInCount;
  final int rationsConsumed;
  final int confirmedCount;

  EventMetricsModel({
    required this.totalCapacity,
    required this.checkedInCount,
    required this.rationsConsumed,
    required this.confirmedCount,
  });

  /// Cupos disponibles = capacidad − participantes confirmados (aceptados).
  int get availableSpots {
    final available = totalCapacity - confirmedCount;
    return available < 0 ? 0 : available;
  }

  factory EventMetricsModel.fromJson(Map<String, dynamic> json) {
    return EventMetricsModel(
      totalCapacity: (json['totalCapacity'] as num?)?.toInt() ?? 0,
      checkedInCount: (json['checkedInCount'] as num?)?.toInt() ?? 0,
      rationsConsumed: (json['rationsConsumed'] as num?)?.toInt() ?? 0,
      confirmedCount: (json['confirmedCount'] as num?)?.toInt() ?? 0,
    );
  }
}
