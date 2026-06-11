import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:campeando_frontend/core/config.dart';

class ApiClient {
  final http.Client _httpClient;

  ApiClient({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  Future<dynamic> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final response = await _httpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      return _handleResponse(response);
    } on SocketException {
      throw Exception('No Internet connection');
    }
  }

  Future<dynamic> post(String path, {required Map<String, dynamic> body}) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final response = await _httpClient.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
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
