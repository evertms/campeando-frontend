abstract class AuthRepository {
  Future<String> login(String email, String password);
  Future<void> register(String email, String password);
  Future<void> logout();
}
