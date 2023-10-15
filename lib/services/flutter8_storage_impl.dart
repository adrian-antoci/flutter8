import 'package:flutter/cupertino.dart';
import 'package:flutter8/services/flutter8_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Flutter8StorageImpl implements Flutter8Storage {
  @override
  Future<bool> storeString(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  @override
  Future<bool> delete(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.remove(key);
  }
}
