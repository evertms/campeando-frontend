import 'dart:convert';
import 'dart:io';

import 'package:campeando_frontend/core/config.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client _httpClient;

  // TODO: Pega aquí tu token JWT para pruebas. ¡No subir esto a git!
  static const String _hardcodedToken =
      "yJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0OTUyODY0Ni01YWUxLTQ2Y2QtYjg3MS00NDc2ZGI3YTE0NWEiLCJlbWFpbCI6ImFkbWluQGRlbW8uY29tIiwianRpIjoiYWZiOTY3NmYtMDc0ZC00NmE5LTk1MWQtZjgxZTJjMmE3MTM2IiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQWRtaW4iLCJ0ZW5hbnRfaWQiOiI4NGYyZDhhMy0xNzQ5LTRhNjgtOGU1Yi04ZTA0MzllMjUxNDQiLCJleHAiOjE3ODEyMDA4OTIsImlzcyI6Imdlc3Rvci1ldmVudG9zIiwiYXVkIjoiZ2VzdG9yLWV2ZW50b3MtY2xpZW50cyJ9.qZTNrnui1YfMJyRkGuRcL5JP-ydUGBvQ9aEMZjO94J8";

  ApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_hardcodedToken',
    };
  }

  Future<dynamic> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final response = await _httpClient.get(uri, headers: _getHeaders());
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
      final response = await _httpClient.post(
        uri,
        headers: _getHeaders(),
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
      // You can handle specific error codes here
      throw Exception('Error ${response.statusCode}: ${response.reasonPhrase}');
    }
  }
}
