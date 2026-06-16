import 'package:campeando_frontend/core/data/api_client.dart';
import 'package:campeando_frontend/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient apiClient;

  AuthRepositoryImpl({required this.apiClient});

  @override
  Future<String> login(String email, String password) async {
    final response = await apiClient.post(
      '/api/identity/login',
      body: {'email': email, 'password': password},
    );

    // Assuming the response is { "accessToken": "...", "refreshToken": "..." }
    // Or just the token string depending on API. OpenAPI says '200' description OK but not schema for response.
    // I'll assume standard { "accessToken": "..." } for now.
    return response['accessToken'] as String;
  }

  @override
  Future<void> register(String email, String password) async {
    await apiClient.post(
      '/api/identity/register',
      body: {'email': email, 'password': password},
    );
  }

  @override
  Future<void> logout() async {
    // In a real app, you might call /api/identity/logout
    // For now, we'll just handle it in the AuthProvider by clearing storage.
  }
}
