abstract class Flutter8Storage {
  Future<bool> storeString(String key, String value);

  Future<bool> delete(String key);

  Future<String?> getString(String key);
}
