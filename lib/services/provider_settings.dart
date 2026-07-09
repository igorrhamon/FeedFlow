import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../providers/auth/auth_config.dart';
import '../providers/provider_registry.dart';

class ProviderSettings {
  static const _storage = FlutterSecureStorage();
  static const _activeProviderKey = 'active_provider';
  static const _authPrefix = 'auth_';
  static const _settingPrefix = 'setting_';

  static Future<void> saveAuthConfig(String providerId, Object config) async {
    final key = '$_authPrefix$providerId';
    String json;
    if (config is GoogleLoginAuthConfig) {
      json = jsonEncode(config.toJson());
    } else if (config is OAuth2AuthConfig) {
      json = jsonEncode(config.toJson());
    } else if (config is ApiKeyAuthConfig) {
      json = jsonEncode(config.toJson());
    } else if (config is BasicAuthConfig) {
      json = jsonEncode(config.toJson());
    } else if (config is LocalOpmlAuthConfig) {
      json = jsonEncode(config.toJson());
    } else {
      return;
    }
    await _storage.write(key: key, value: json);
  }

  static Future<Object?> loadAuthConfig(String providerId) async {
    final key = '$_authPrefix$providerId';
    final json = await _storage.read(key: key);
    if (json == null) return null;
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      final type = map['type'] as String? ?? '';
      switch (type) {
        case 'googleLogin':
          return GoogleLoginAuthConfig.fromJson(map);
        case 'oauth2':
          return OAuth2AuthConfig.fromJson(map);
        case 'apiKey':
          return ApiKeyAuthConfig.fromJson(map);
        case 'basicAuth':
          return BasicAuthConfig.fromJson(map);
        case 'localOpml':
          return LocalOpmlAuthConfig.fromJson(map);
        default:
          return null;
      }
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearAuthConfig(String providerId) async {
    await _storage.delete(key: '$_authPrefix$providerId');
  }

  static Future<void> setActiveProvider(String providerId) async {
    await _storage.write(key: _activeProviderKey, value: providerId);
  }

  static Future<String?> getActiveProvider() async {
    return _storage.read(key: _activeProviderKey);
  }

  static Future<void> saveProviderSetting(String providerId, String key, String value) async {
    await _storage.write(key: '$_settingPrefix${providerId}_$key', value: value);
  }

  static Future<String?> getProviderSetting(String providerId, String key) async {
    return _storage.read(key: '$_settingPrefix${providerId}_$key');
  }

  static Future<void> clearProviderSettings(String providerId) async {
    final keys = await _storage.readAll();
    for (final key in keys.keys) {
      if (key.startsWith('$_settingPrefix$providerId') || key == '$_authPrefix$providerId') {
        await _storage.delete(key: key);
      }
    }
  }

  static Future<Map<String, bool>> getConnectedProviders() async {
    final result = <String, bool>{};
    final providers = ProviderRegistry.getAvailableProviders();
    for (final info in providers) {
      final auth = await loadAuthConfig(info.id);
      result[info.id] = auth != null;
    }
    return result;
  }
}