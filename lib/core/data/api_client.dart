import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:campeando_frontend/core/config.dart';
import 'package:campeando_frontend/core/data/storage_service.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client _httpClient;
  final StorageService? _storageService;

  /// Tiempo máximo por request. Evita spinners eternos cuando la red se cuelga.
  static const Duration _timeout = Duration(seconds: 15);

  /// Hook invocado ante un 401. Debe intentar renovar la sesión y devolver
  /// `true` si lo logró (conviene reintentar la request) o `false` si no
  /// (se fuerza el logout aguas arriba). Lo cablea [AuthProvider].
  Future<bool> Function()? onUnauthorized;

  ApiClient({http.Client? httpClient, this._storageService})
    : _httpClient = httpClient ?? http.Client();

  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (_storageService != null) {
      final token = await _storageService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final tenantId = await _storageService.getTenant();
      if (tenantId != null) {
        // Clean any potential quotes like the ones mentioned by the user
        final cleanTenantId = tenantId.replaceAll('"', '').trim();
        headers['X-Tenant-Id'] = cleanTenantId;
      }
    }

    return headers;
  }

  Future<dynamic> get(String path) => _request('GET', path);

  Future<dynamic> post(
    String path, {
    required Map<String, dynamic> body,
    bool allowRefresh = true,
  }) => _request('POST', path, body: body, allowRefresh: allowRefresh);

  Future<dynamic> patch(
    String path, {
    required Map<String, dynamic> body,
    bool allowRefresh = true,
  }) => _request('PATCH', path, body: body, allowRefresh: allowRefresh);

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool allowRefresh = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      var headers = await _getHeaders();
      var response = await _dispatch(method, uri, headers, body);

      // Ante un 401, intentamos renovar la sesión una sola vez y reintentar.
      if (response.statusCode == 401 &&
          allowRefresh &&
          onUnauthorized != null) {
        final renewed = await onUnauthorized!.call();
        if (renewed) {
          headers = await _getHeaders(); // ya con el token nuevo
          response = await _dispatch(method, uri, headers, body);
        }
      }

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No Internet connection');
    } on TimeoutException {
      throw Exception('La conexión tardó demasiado. Intentá de nuevo.');
    }
  }

  Future<http.Response> _dispatch(
    String method,
    Uri uri,
    Map<String, String> headers,
    Map<String, dynamic>? body,
  ) {
    switch (method) {
      case 'POST':
        return _httpClient
            .post(uri, headers: headers, body: json.encode(body))
            .timeout(_timeout);
      case 'PATCH':
        return _httpClient
            .patch(uri, headers: headers, body: json.encode(body))
            .timeout(_timeout);
      case 'GET':
      default:
        return _httpClient.get(uri, headers: headers).timeout(_timeout);
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return json.decode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}: ${response.reasonPhrase}');
    }
  }
}
