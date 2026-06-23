import 'dart:convert';
import 'dart:io';

import 'package:campeando_frontend/core/config.dart';
import 'package:campeando_frontend/core/data/storage_service.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client _httpClient;
  final StorageService? _storageService;

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

  Future<dynamic> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final headers = await _getHeaders();
      final response = await _httpClient.get(uri, headers: headers);
      return _handleResponse(response);
    } on SocketException {
      throw Exception('No Internet connection');
    }
  }

  Future<dynamic> post(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final headers = await _getHeaders();
      final response = await _httpClient.post(
        uri,
        headers: headers,
        body: json.encode(body),
      );
      return _handleResponse(response);
    } on SocketException {
      throw Exception('No Internet connection');
    }
  }

  Future<dynamic> patch(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final headers = await _getHeaders();
      final response = await _httpClient.patch(
        uri,
        headers: headers,
        body: json.encode(body),
      );
      return _handleResponse(response);
    } on SocketException {
      throw Exception('No Internet connection');
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
