import 'package:http/http.dart' as http;

import 'storage_service.dart';

/// TODO: Interceptor simple para enriquecer headers antes de cada request.
typedef HeaderInterceptor = Future<Map<String, String>> Function(
  Map<String, String> headers,
);

/// TODO: Cliente base para requests HTTP con inyección automática de JWT y Tenant.
class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.storageService,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final StorageService storageService;
  final http.Client _httpClient;

  final List<HeaderInterceptor> _interceptors = [];

  /// TODO: Registrar interceptores para modificar headers antes de enviar la petición.
  void addInterceptor(HeaderInterceptor interceptor) {
    _interceptors.add(interceptor);
  }

  /// TODO: Ejecutar una petición GET con headers base + JWT + Tenant.
  Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    throw UnimplementedError('TODO: implementar GET con headers e interceptores');
  }

  /// TODO: Ejecutar una petición POST con headers base + JWT + Tenant.
  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    throw UnimplementedError('TODO: implementar POST con headers e interceptores');
  }
}