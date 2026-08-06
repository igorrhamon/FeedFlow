// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'local_source_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LocalSourceConfig _$LocalSourceConfigFromJson(Map<String, dynamic> json) {
  return _LocalSourceConfig.fromJson(json);
}

/// @nodoc
mixin _$LocalSourceConfig {
  /// ID único da configuração de fonte.
  String get id => throw _privateConstructorUsedError;

  /// Tipo da fonte: pasta, Obsidian vault, PDF, ou Office.
  LocalSourceType get type => throw _privateConstructorUsedError;

  /// Caminho absoluto no disco da pasta/arquivo raiz.
  String get path => throw _privateConstructorUsedError;

  /// Rótulo humanizado para exibição na UI (ex.: "Minhas notas", "PDFs de pesquisa").
  String get label => throw _privateConstructorUsedError;

  /// Se esta fonte está habilitada para sincronização.
  bool get enabled => throw _privateConstructorUsedError;

  /// Última vez que esta fonte foi sincronizada com sucesso.
  DateTime? get lastSyncAt => throw _privateConstructorUsedError;

  /// Quando a configuração foi criada.
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this LocalSourceConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LocalSourceConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocalSourceConfigCopyWith<LocalSourceConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocalSourceConfigCopyWith<$Res> {
  factory $LocalSourceConfigCopyWith(
    LocalSourceConfig value,
    $Res Function(LocalSourceConfig) then,
  ) = _$LocalSourceConfigCopyWithImpl<$Res, LocalSourceConfig>;
  @useResult
  $Res call({
    String id,
    LocalSourceType type,
    String path,
    String label,
    bool enabled,
    DateTime? lastSyncAt,
    DateTime createdAt,
  });
}

/// @nodoc
class _$LocalSourceConfigCopyWithImpl<$Res, $Val extends LocalSourceConfig>
    implements $LocalSourceConfigCopyWith<$Res> {
  _$LocalSourceConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocalSourceConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? path = null,
    Object? label = null,
    Object? enabled = null,
    Object? lastSyncAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as LocalSourceType,
            path:
                null == path
                    ? _value.path
                    : path // ignore: cast_nullable_to_non_nullable
                        as String,
            label:
                null == label
                    ? _value.label
                    : label // ignore: cast_nullable_to_non_nullable
                        as String,
            enabled:
                null == enabled
                    ? _value.enabled
                    : enabled // ignore: cast_nullable_to_non_nullable
                        as bool,
            lastSyncAt:
                freezed == lastSyncAt
                    ? _value.lastSyncAt
                    : lastSyncAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LocalSourceConfigImplCopyWith<$Res>
    implements $LocalSourceConfigCopyWith<$Res> {
  factory _$$LocalSourceConfigImplCopyWith(
    _$LocalSourceConfigImpl value,
    $Res Function(_$LocalSourceConfigImpl) then,
  ) = __$$LocalSourceConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    LocalSourceType type,
    String path,
    String label,
    bool enabled,
    DateTime? lastSyncAt,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$LocalSourceConfigImplCopyWithImpl<$Res>
    extends _$LocalSourceConfigCopyWithImpl<$Res, _$LocalSourceConfigImpl>
    implements _$$LocalSourceConfigImplCopyWith<$Res> {
  __$$LocalSourceConfigImplCopyWithImpl(
    _$LocalSourceConfigImpl _value,
    $Res Function(_$LocalSourceConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LocalSourceConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? path = null,
    Object? label = null,
    Object? enabled = null,
    Object? lastSyncAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$LocalSourceConfigImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as LocalSourceType,
        path:
            null == path
                ? _value.path
                : path // ignore: cast_nullable_to_non_nullable
                    as String,
        label:
            null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                    as String,
        enabled:
            null == enabled
                ? _value.enabled
                : enabled // ignore: cast_nullable_to_non_nullable
                    as bool,
        lastSyncAt:
            freezed == lastSyncAt
                ? _value.lastSyncAt
                : lastSyncAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LocalSourceConfigImpl implements _LocalSourceConfig {
  const _$LocalSourceConfigImpl({
    required this.id,
    required this.type,
    required this.path,
    required this.label,
    this.enabled = true,
    this.lastSyncAt,
    required this.createdAt,
  });

  factory _$LocalSourceConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocalSourceConfigImplFromJson(json);

  /// ID único da configuração de fonte.
  @override
  final String id;

  /// Tipo da fonte: pasta, Obsidian vault, PDF, ou Office.
  @override
  final LocalSourceType type;

  /// Caminho absoluto no disco da pasta/arquivo raiz.
  @override
  final String path;

  /// Rótulo humanizado para exibição na UI (ex.: "Minhas notas", "PDFs de pesquisa").
  @override
  final String label;

  /// Se esta fonte está habilitada para sincronização.
  @override
  @JsonKey()
  final bool enabled;

  /// Última vez que esta fonte foi sincronizada com sucesso.
  @override
  final DateTime? lastSyncAt;

  /// Quando a configuração foi criada.
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'LocalSourceConfig(id: $id, type: $type, path: $path, label: $label, enabled: $enabled, lastSyncAt: $lastSyncAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocalSourceConfigImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.lastSyncAt, lastSyncAt) ||
                other.lastSyncAt == lastSyncAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    path,
    label,
    enabled,
    lastSyncAt,
    createdAt,
  );

  /// Create a copy of LocalSourceConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocalSourceConfigImplCopyWith<_$LocalSourceConfigImpl> get copyWith =>
      __$$LocalSourceConfigImplCopyWithImpl<_$LocalSourceConfigImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LocalSourceConfigImplToJson(this);
  }
}

abstract class _LocalSourceConfig implements LocalSourceConfig {
  const factory _LocalSourceConfig({
    required final String id,
    required final LocalSourceType type,
    required final String path,
    required final String label,
    final bool enabled,
    final DateTime? lastSyncAt,
    required final DateTime createdAt,
  }) = _$LocalSourceConfigImpl;

  factory _LocalSourceConfig.fromJson(Map<String, dynamic> json) =
      _$LocalSourceConfigImpl.fromJson;

  /// ID único da configuração de fonte.
  @override
  String get id;

  /// Tipo da fonte: pasta, Obsidian vault, PDF, ou Office.
  @override
  LocalSourceType get type;

  /// Caminho absoluto no disco da pasta/arquivo raiz.
  @override
  String get path;

  /// Rótulo humanizado para exibição na UI (ex.: "Minhas notas", "PDFs de pesquisa").
  @override
  String get label;

  /// Se esta fonte está habilitada para sincronização.
  @override
  bool get enabled;

  /// Última vez que esta fonte foi sincronizada com sucesso.
  @override
  DateTime? get lastSyncAt;

  /// Quando a configuração foi criada.
  @override
  DateTime get createdAt;

  /// Create a copy of LocalSourceConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocalSourceConfigImplCopyWith<_$LocalSourceConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
