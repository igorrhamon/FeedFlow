import 'package:freezed_annotation/freezed_annotation.dart';
import '../../models/feed.dart';
import '../../models/category.dart';

part 'auth_config.freezed.dart';
part 'auth_config.g.dart';

@freezed
class GoogleLoginAuthConfig with _$GoogleLoginAuthConfig {
  const factory GoogleLoginAuthConfig({
    @Default('googleLogin') String type,
    required String providerId,
    required String email,
    String? password,
    required String authToken,
  }) = _GoogleLoginAuthConfig;

  factory GoogleLoginAuthConfig.fromJson(Map<String, dynamic> json) => 
      _$GoogleLoginAuthConfigFromJson(json);
}

@freezed
class OAuth2AuthConfig with _$OAuth2AuthConfig {
  const factory OAuth2AuthConfig({
    @Default('oauth2') String type,
    required String providerId,
    required String clientId,
    required String clientSecret,
    required String accessToken,
    required String refreshToken,
    required String expiresAt,
    @Default([]) List<String> scopes,
  }) = _OAuth2AuthConfig;

  factory OAuth2AuthConfig.fromJson(Map<String, dynamic> json) => 
      _$OAuth2AuthConfigFromJson(json);
}

@freezed
class ApiKeyAuthConfig with _$ApiKeyAuthConfig {
  const factory ApiKeyAuthConfig({
    @Default('apiKey') String type,
    required String providerId,
    required String apiKey,
    String? apiSecret,
    String? baseUrl,
  }) = _ApiKeyAuthConfig;

  factory ApiKeyAuthConfig.fromJson(Map<String, dynamic> json) => 
      _$ApiKeyAuthConfigFromJson(json);
}

@freezed
class BasicAuthConfig with _$BasicAuthConfig {
  const factory BasicAuthConfig({
    @Default('basicAuth') String type,
    required String providerId,
    required String username,
    required String password,
    String? baseUrl,
  }) = _BasicAuthConfig;

  factory BasicAuthConfig.fromJson(Map<String, dynamic> json) => 
      _$BasicAuthConfigFromJson(json);
}

@freezed
class LocalOpmlAuthConfig with _$LocalOpmlAuthConfig {
  const factory LocalOpmlAuthConfig({
    @Default('localOpml') String type,
    required String providerId,
    required String filePath,
  }) = _LocalOpmlAuthConfig;

  factory LocalOpmlAuthConfig.fromJson(Map<String, dynamic> json) => 
      _$LocalOpmlAuthConfigFromJson(json);
}

@freezed
class AuthResult with _$AuthResult {
  const factory AuthResult({
    required bool success,
    Object? config,
    String? error,
    String? userId,
    String? userName,
  }) = _AuthResult;

  factory AuthResult.fromJson(Map<String, dynamic> json) => _$AuthResultFromJson(json);
}

@freezed
class FeedResult with _$FeedResult {
  const factory FeedResult({
    required bool success,
    String? feedId,
    String? error,
    Feed? feed,
  }) = _FeedResult;

  factory FeedResult.fromJson(Map<String, dynamic> json) => _$FeedResultFromJson(json);
}

@freezed
class CategoryResult with _$CategoryResult {
  const factory CategoryResult({
    required bool success,
    String? categoryId,
    String? error,
    Category? category,
  }) = _CategoryResult;

  factory CategoryResult.fromJson(Map<String, dynamic> json) => _$CategoryResultFromJson(json);
}

@freezed
class OpmlImportResult with _$OpmlImportResult {
  const factory OpmlImportResult({
    required bool success,
    @Default([]) List<Feed> feeds,
    @Default([]) List<String> errors,
  }) = _OpmlImportResult;

  factory OpmlImportResult.fromJson(Map<String, dynamic> json) => _$OpmlImportResultFromJson(json);
}

