/// Abstract class defining the contract for local storage operations
/// This allows us to easily swap implementations and makes testing easier
abstract class LocalStorageService {
  /// Gets a string value by key
  Future<String?> getString(String key);

  /// Sets a string value by key
  Future<bool> setString(String key, String value);

  /// Gets a boolean value by key
  Future<bool?> getBool(String key);

  /// Sets a boolean value by key
  Future<bool> setBool(String key, bool value);

  /// Gets an integer value by key
  Future<int?> getInt(String key);

  /// Sets an integer value by key
  Future<bool> setInt(String key, int value);

  /// Gets a double value by key
  Future<double?> getDouble(String key);

  /// Sets a double value by key
  Future<bool> setDouble(String key, double value);

  /// Gets a list of strings by key
  Future<List<String>?> getStringList(String key);

  /// Sets a list of strings by key
  Future<bool> setStringList(String key, List<String> value);

  /// Removes a value by key
  Future<bool> remove(String key);

  /// Clears all stored values
  Future<bool> clear();

  /// Checks if a key exists
  Future<bool> containsKey(String key);

  /// Gets all keys
  Future<Set<String>> getKeys();
}
