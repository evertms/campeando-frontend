import 'package:campeando_frontend/core/config.dart';

class EventDetailModel {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final int maxCapacity;
  final String? coverImageUrl;
  final String? paymentQrImageUrl;

  EventDetailModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.maxCapacity,
    this.coverImageUrl,
    this.paymentQrImageUrl,
  });

  factory EventDetailModel.fromJson(Map<String, dynamic> json) {
    return EventDetailModel(
      id: json['id'],
      name: json['name'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      maxCapacity: json['maxCapacity'],
      coverImageUrl: _resolveUrl(json['coverImageUrl'] as String?),
      paymentQrImageUrl: _resolveUrl(json['paymentQrImageUrl'] as String?),
    );
  }

  // El backend devuelve rutas relativas (/events/.., /payment-qrs/..); las
  // resolvemos contra el host de la API para que Image.network las cargue.
  static String? _resolveUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('/')) return '$baseUrl$path';
    return path;
  }
}
