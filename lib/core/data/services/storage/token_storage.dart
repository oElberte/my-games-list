/// Abstraction for securely persisting the authentication token.
abstract class TokenStorage {
  Future<void> write(String token);
  Future<String?> read();
  Future<void> delete();
}
