import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

class EncryptionService {
  static const _keyName = 'hive_prefs_aes_key';
  static const _storage = FlutterSecureStorage();

  /// Returns a cipher backed by a key stored in the OS keychain (iOS/macOS)
  /// or EncryptedSharedPreferences (Android). On web, the key is stored in
  /// localStorage — data is still encrypted at rest in IndexedDB.
  static Future<HiveAesCipher> getOrCreateCipher() async {
    String? encoded = await _storage.read(key: _keyName);
    if (encoded == null) {
      final key = List<int>.generate(32, (_) => Random.secure().nextInt(256));
      encoded = base64UrlEncode(key);
      await _storage.write(key: _keyName, value: encoded);
    }
    final keyBytes = base64Url.decode(encoded);
    return HiveAesCipher(keyBytes);
  }
}
