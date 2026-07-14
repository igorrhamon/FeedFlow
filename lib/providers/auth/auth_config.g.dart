// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GoogleLoginAuthConfigImpl _$$GoogleLoginAuthConfigImplFromJson(
  Map<String, dynamic> json,
) => _$GoogleLoginAuthConfigImpl(
  type: json['type'] as String? ?? 'googleLogin',
  providerId: json['providerId'] as String,
  email: json['email'] as String,
  password: json['password'] as String?,
  authToken: json['authToken'] as String,
);

Map<String, dynamic> _$$GoogleLoginAuthConfigImplToJson(
  _$GoogleLoginAuthConfigImpl instance,
) => <String, dynamic>{
  'type': instance.type,
  'providerId': instance.providerId,
  'email': instance.email,
  'password': instance.password,
  'authToken': instance.authToken,
};

_$OAuth2AuthConfigImpl _$$OAuth2AuthConfigImplFromJson(
  Map<String, dynamic> json,
) => _$OAuth2AuthConfigImpl(
  type: json['type'] as String? ?? 'oauth2',
  providerId: json['providerId'] as String,
  clientId: json['clientId'] as String,
  clientSecret: json['clientSecret'] as String,
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
  expiresAt: json['expiresAt'] as String,
  scopes:
      (json['scopes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$$OAuth2AuthConfigImplToJson(
  _$OAuth2AuthConfigImpl instance,
) => <String, dynamic>{
  'type': instance.type,
  'providerId': instance.providerId,
  'clientId': instance.clientId,
  'clientSecret': instance.clientSecret,
  'accessToken': instance.accessToken,
  'refreshToken': instance.refreshToken,
  'expiresAt': instance.expiresAt,
  'scopes': instance.scopes,
};

_$ApiKeyAuthConfigImpl _$$ApiKeyAuthConfigImplFromJson(
  Map<String, dynamic> json,
) => _$ApiKeyAuthConfigImpl(
  type: json['type'] as String? ?? 'apiKey',
  providerId: json['providerId'] as String,
  apiKey: json['apiKey'] as String,
  apiSecret: json['apiSecret'] as String?,
  baseUrl: json['baseUrl'] as String?,
);

Map<String, dynamic> _$$ApiKeyAuthConfigImplToJson(
  _$ApiKeyAuthConfigImpl instance,
) => <String, dynamic>{
  'type': instance.type,
  'providerId': instance.providerId,
  'apiKey': instance.apiKey,
  'apiSecret': instance.apiSecret,
  'baseUrl': instance.baseUrl,
};

_$BasicAuthConfigImpl _$$BasicAuthConfigImplFromJson(
  Map<String, dynamic> json,
) => _$BasicAuthConfigImpl(
  type: json['type'] as String? ?? 'basicAuth',
  providerId: json['providerId'] as String,
  username: json['username'] as String,
  password: json['password'] as String,
  baseUrl: json['baseUrl'] as String?,
);

Map<String, dynamic> _$$BasicAuthConfigImplToJson(
  _$BasicAuthConfigImpl instance,
) => <String, dynamic>{
  'type': instance.type,
  'providerId': instance.providerId,
  'username': instance.username,
  'password': instance.password,
  'baseUrl': instance.baseUrl,
};

_$LocalOpmlAuthConfigImpl _$$LocalOpmlAuthConfigImplFromJson(
  Map<String, dynamic> json,
) => _$LocalOpmlAuthConfigImpl(
  type: json['type'] as String? ?? 'localOpml',
  providerId: json['providerId'] as String,
  filePath: json['filePath'] as String,
);

Map<String, dynamic> _$$LocalOpmlAuthConfigImplToJson(
  _$LocalOpmlAuthConfigImpl instance,
) => <String, dynamic>{
  'type': instance.type,
  'providerId': instance.providerId,
  'filePath': instance.filePath,
};

_$AuthResultImpl _$$AuthResultImplFromJson(Map<String, dynamic> json) =>
    _$AuthResultImpl(
      success: json['success'] as bool,
      config: json['config'],
      error: json['error'] as String?,
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
    );

Map<String, dynamic> _$$AuthResultImplToJson(_$AuthResultImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'config': instance.config,
      'error': instance.error,
      'userId': instance.userId,
      'userName': instance.userName,
    };

_$FeedResultImpl _$$FeedResultImplFromJson(Map<String, dynamic> json) =>
    _$FeedResultImpl(
      success: json['success'] as bool,
      feedId: json['feedId'] as String?,
      error: json['error'] as String?,
      feed:
          json['feed'] == null
              ? null
              : Feed.fromJson(json['feed'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$FeedResultImplToJson(_$FeedResultImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'feedId': instance.feedId,
      'error': instance.error,
      'feed': instance.feed?.toJson(),
    };

_$CategoryResultImpl _$$CategoryResultImplFromJson(Map<String, dynamic> json) =>
    _$CategoryResultImpl(
      success: json['success'] as bool,
      categoryId: json['categoryId'] as String?,
      error: json['error'] as String?,
      category:
          json['category'] == null
              ? null
              : Category.fromJson(json['category'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CategoryResultImplToJson(
  _$CategoryResultImpl instance,
) => <String, dynamic>{
  'success': instance.success,
  'categoryId': instance.categoryId,
  'error': instance.error,
  'category': instance.category?.toJson(),
};

_$OpmlImportResultImpl _$$OpmlImportResultImplFromJson(
  Map<String, dynamic> json,
) => _$OpmlImportResultImpl(
  success: json['success'] as bool,
  feeds:
      (json['feeds'] as List<dynamic>?)
          ?.map((e) => Feed.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  errors:
      (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$$OpmlImportResultImplToJson(
  _$OpmlImportResultImpl instance,
) => <String, dynamic>{
  'success': instance.success,
  'feeds': instance.feeds.map((e) => e.toJson()).toList(),
  'errors': instance.errors,
};
