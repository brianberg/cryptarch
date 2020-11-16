import "dart:convert";

import "package:flutter_secure_storage/flutter_secure_storage.dart";

class StorageService {
  static Future<dynamic> getItem(String key) async {
    final storage = FlutterSecureStorage();
    String value = await storage.read(key: key);
    return value != null ? jsonDecode(value) : null;
  }

  static Future<void> putItem(String key, dynamic value) {
    final storage = FlutterSecureStorage();
    return storage.write(
      key: key,
      value: value != null ? jsonEncode(value) : null,
    );
  }

  static Future<void> removeItem(String key) {
    final storage = FlutterSecureStorage();
    return storage.delete(key: key);
  }
}
