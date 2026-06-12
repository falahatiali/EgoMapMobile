import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

/// Persists auth and guest tokens via Keychain/Keystore with a local file backup
/// so sessions survive hot restart when the macOS Keychain plugin reconnects slowly.
class AppLocalStorage {
  AppLocalStorage({FlutterSecureStorage? secure})
      : _secure = secure ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
              mOptions: MacOsOptions(),
            );

  static const apiTokenKey = 'egomap_api_token';
  static const guestTokenKey = 'egomap_guest_token';
  static const quizSessionKeyPrefix = 'egomap_quiz_session_';
  static const _backupFileName = 'egomap_storage_backup.json';

  final FlutterSecureStorage _secure;
  final Map<String, String> _memory = {};
  bool _loggedSecureFallback = false;
  File? _backupFile;
  Map<String, String>? _backupCache;

  static String quizSessionKey(String slug) => '$quizSessionKeyPrefix$slug';

  Future<File> _backupFilePath() async {
    _backupFile ??= File(
      '${(await getApplicationSupportDirectory()).path}/$_backupFileName',
    );

    return _backupFile!;
  }

  Future<Map<String, String>> _readBackupMap() async {
    if (_backupCache != null) {
      return _backupCache!;
    }

    try {
      final file = await _backupFilePath();
      if (!await file.exists()) {
        _backupCache = {};
        return _backupCache!;
      }

      final raw = await file.readAsString();
      final decoded = jsonDecode(raw);

      if (decoded is! Map) {
        _backupCache = {};
        return _backupCache!;
      }

      _backupCache = decoded.map(
        (key, value) => MapEntry('$key', '$value'),
      );

      return _backupCache!;
    } catch (_) {
      _backupCache = {};
      return _backupCache!;
    }
  }

  Future<void> _writeBackupMap(Map<String, String> values) async {
    _backupCache = Map<String, String>.from(values);

    try {
      final file = await _backupFilePath();
      await file.writeAsString(jsonEncode(values));
    } catch (_) {}
  }

  Future<void> _writeBackup(String key, String value) async {
    final backup = await _readBackupMap();
    backup[key] = value;
    await _writeBackupMap(backup);
  }

  Future<String?> _readBackup(String key) async {
    final backup = await _readBackupMap();
    return backup[key];
  }

  Future<void> _deleteBackup(String key) async {
    final backup = await _readBackupMap();
    backup.remove(key);
    await _writeBackupMap(backup);
  }

  Future<String?> read(String key) async {
    if (_memory.containsKey(key)) {
      return _memory[key];
    }

    try {
      final secureValue = await _secure.read(key: key);
      if (secureValue != null && secureValue.isNotEmpty) {
        _memory[key] = secureValue;
        await _writeBackup(key, secureValue);
        return secureValue;
      }
    } catch (error) {
      _logSecureFallbackOnce();
    }

    final backupValue = await _readBackup(key);
    if (backupValue != null && backupValue.isNotEmpty) {
      _memory[key] = backupValue;

      try {
        await _secure.write(key: key, value: backupValue);
      } catch (_) {
        _logSecureFallbackOnce();
      }

      return backupValue;
    }

    return null;
  }

  Future<void> write(String key, String value) async {
    _memory[key] = value;
    await _writeBackup(key, value);

    try {
      await _secure.write(key: key, value: value);
    } catch (error) {
      _logSecureFallbackOnce();
    }
  }

  Future<void> delete(String key) async {
    _memory.remove(key);
    await _deleteBackup(key);

    try {
      await _secure.delete(key: key);
    } catch (_) {}
  }

  void _logSecureFallbackOnce() {
    if (!kDebugMode || _loggedSecureFallback) {
      return;
    }

    _loggedSecureFallback = true;
    debugPrint(
      'Secure storage unavailable — using local file backup for this session.',
    );
  }

  Future<String?> readApiToken() => read(apiTokenKey);

  Future<void> writeApiToken(String token) => write(apiTokenKey, token);

  Future<void> clearApiToken() => delete(apiTokenKey);

  Future<String?> readGuestToken() => read(guestTokenKey);

  Future<void> writeGuestToken(String token) => write(guestTokenKey, token);

  Future<String?> readQuizSessionUuid(String slug) => read(quizSessionKey(slug));

  Future<void> writeQuizSessionUuid(String slug, String uuid) =>
      write(quizSessionKey(slug), uuid);
}
