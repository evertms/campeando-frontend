import 'package:campeando_frontend/core/data/api_client.dart';
import 'package:campeando_frontend/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient apiClient;

  AuthRepositoryImpl({required this.apiClient});

  @override
  Future<AuthTokens> login(String email, String password) async {
    final response = await apiClient.post(
      '/api/identity/login',
      body: {'email': email, 'password': password},
    );
    return _tokensFrom(response);
  }

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    // `allowRefresh: false` evita que un 401 del propio refresh dispare otro
    // intento de refresh (recursión).
    // El backend espera la propiedad `token` (ver RefreshTokenCommand.cs) y
    // devuelve { accessToken, refreshToken } (RefreshTokenResponse.cs).
    final response = await apiClient.post(
      '/api/identity/refresh',
      body: {'token': refreshToken},
      allowRefresh: false,
    );
    return _tokensFrom(response);
  }

  AuthTokens _tokensFrom(dynamic response) {
    final map = response as Map<String, dynamic>;
    return AuthTokens(
      accessToken: map['accessToken'] as String,
      refreshToken: map['refreshToken'] as String?,
    );
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
