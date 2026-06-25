/// Par de tokens devueltos por el backend al iniciar sesión o al renovar.
/// `refreshToken` puede ser null si el backend no rota el refresh en cada uso.
class AuthTokens {
  final String accessToken;
  final String? refreshToken;

  const AuthTokens({required this.accessToken, this.refreshToken});
}

abstract class AuthRepository {
  Future<AuthTokens> login(String email, String password);

  /// Renueva el access token usando el refresh token almacenado.
  Future<AuthTokens> refresh(String refreshToken);

  Future<void> register(String email, String password);
  Future<void> logout();
}
