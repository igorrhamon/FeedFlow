// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Document _$DocumentFromJson(Map<String, dynamic> json) {
  return _Document.fromJson(json);
}

/// @nodoc
mixin _$Document {
  String get id => throw _privateConstructorUsedError;

  /// Identificador do conector que originou este documento.
  /// Exemplos: 'rss:the-old-reader', 'email:gmail', 'local-note'.
  String get sourceConnectorId => throw _privateConstructorUsedError;

  /// ID do documento na origem (UID de email, URL de artigo, etc.).
  /// Único por conector, não globalmente.
  String get sourceId => throw _privateConstructorUsedError;

  /// Tipo MIME do conteúdo (ex.: 'text/markdown', 'text/html', 'application/pdf').
  String get contentType => throw _privateConstructorUsedError;

  /// Título/assunto do conteúdo.
  String get title => throw _privateConstructorUsedError;

  /// Autor, remetente ou criador do conteúdo (nullable — PDFs/emails podem não ter).
  String? get author => throw _privateConstructorUsedError;

  /// Conteúdo bruto: HTML, Markdown, texto plano, ou serialização de estrutura
  /// (ex.: JSON extraído de um webhook). Pode ser nulo para anexos.
  String? get rawContent => throw _privateConstructorUsedError;

  /// URL de origem (link do artigo, URL do email, etc.). Nullable.
  String? get url => throw _privateConstructorUsedError;

  /// Quando o conteúdo foi publicado/criado na origem.
  DateTime get capturedAt => throw _privateConstructorUsedError;

  /// Metadados adicionais específicos do conector, serializados como JSON.
  /// Exemplos: `{ "workItemId": "...", "tags": [...], "attachmentCount": 2 }`.
  String? get metadataJson => throw _privateConstructorUsedError;

  /// Serializes this Document to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Document
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DocumentCopyWith<Document> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentCopyWith<$Res> {
  factory $DocumentCopyWith(Document value, $Res Function(Document) then) =
      _$DocumentCopyWithImpl<$Res, Document>;
  @useResult
  $Res call({
    String id,
    String sourceConnectorId,
    String sourceId,
    String contentType,
    String title,
    String? author,
    String? rawContent,
    String? url,
    DateTime capturedAt,
    String? metadataJson,
  });
}

/// @nodoc
class _$DocumentCopyWithImpl<$Res, $Val extends Document>
    implements $DocumentCopyWith<$Res> {
  _$DocumentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Document
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sourceConnectorId = null,
    Object? sourceId = null,
    Object? contentType = null,
    Object? title = null,
    Object? author = freezed,
    Object? rawContent = freezed,
    Object? url = freezed,
    Object? capturedAt = null,
    Object? metadataJson = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            sourceConnectorId:
                null == sourceConnectorId
                    ? _value.sourceConnectorId
                    : sourceConnectorId // ignore: cast_nullable_to_non_nullable
                        as String,
            sourceId:
                null == sourceId
                    ? _value.sourceId
                    : sourceId // ignore: cast_nullable_to_non_nullable
                        as String,
            contentType:
                null == contentType
                    ? _value.contentType
                    : contentType // ignore: cast_nullable_to_non_nullable
                        as String,
            title:
                null == title
                    ? _value.title
                    : title // ignore: cast_nullable_to_non_nullable
                        as String,
            author:
                freezed == author
                    ? _value.author
                    : author // ignore: cast_nullable_to_non_nullable
                        as String?,
            rawContent:
                freezed == rawContent
                    ? _value.rawContent
                    : rawContent // ignore: cast_nullable_to_non_nullable
                        as String?,
            url:
                freezed == url
                    ? _value.url
                    : url // ignore: cast_nullable_to_non_nullable
                        as String?,
            capturedAt:
                null == capturedAt
                    ? _value.capturedAt
                    : capturedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            metadataJson:
                freezed == metadataJson
                    ? _value.metadataJson
                    : metadataJson // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DocumentImplCopyWith<$Res>
    implements $DocumentCopyWith<$Res> {
  factory _$$DocumentImplCopyWith(
    _$DocumentImpl value,
    $Res Function(_$DocumentImpl) then,
  ) = __$$DocumentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String sourceConnectorId,
    String sourceId,
    String contentType,
    String title,
    String? author,
    String? rawContent,
    String? url,
    DateTime capturedAt,
    String? metadataJson,
  });
}

/// @nodoc
class __$$DocumentImplCopyWithImpl<$Res>
    extends _$DocumentCopyWithImpl<$Res, _$DocumentImpl>
    implements _$$DocumentImplCopyWith<$Res> {
  __$$DocumentImplCopyWithImpl(
    _$DocumentImpl _value,
    $Res Function(_$DocumentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Document
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sourceConnectorId = null,
    Object? sourceId = null,
    Object? contentType = null,
    Object? title = null,
    Object? author = freezed,
    Object? rawContent = freezed,
    Object? url = freezed,
    Object? capturedAt = null,
    Object? metadataJson = freezed,
  }) {
    return _then(
      _$DocumentImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        sourceConnectorId:
            null == sourceConnectorId
                ? _value.sourceConnectorId
                : sourceConnectorId // ignore: cast_nullable_to_non_nullable
                    as String,
        sourceId:
            null == sourceId
                ? _value.sourceId
                : sourceId // ignore: cast_nullable_to_non_nullable
                    as String,
        contentType:
            null == contentType
                ? _value.contentType
                : contentType // ignore: cast_nullable_to_non_nullable
                    as String,
        title:
            null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                    as String,
        author:
            freezed == author
                ? _value.author
                : author // ignore: cast_nullable_to_non_nullable
                    as String?,
        rawContent:
            freezed == rawContent
                ? _value.rawContent
                : rawContent // ignore: cast_nullable_to_non_nullable
                    as String?,
        url:
            freezed == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                    as String?,
        capturedAt:
            null == capturedAt
                ? _value.capturedAt
                : capturedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        metadataJson:
            freezed == metadataJson
                ? _value.metadataJson
                : metadataJson // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DocumentImpl extends _Document {
  const _$DocumentImpl({
    required this.id,
    required this.sourceConnectorId,
    required this.sourceId,
    required this.contentType,
    required this.title,
    this.author,
    this.rawContent,
    this.url,
    required this.capturedAt,
    this.metadataJson,
  }) : super._();

  factory _$DocumentImpl.fromJson(Map<String, dynamic> json) =>
      _$$DocumentImplFromJson(json);

  @override
  final String id;

  /// Identificador do conector que originou este documento.
  /// Exemplos: 'rss:the-old-reader', 'email:gmail', 'local-note'.
  @override
  final String sourceConnectorId;

  /// ID do documento na origem (UID de email, URL de artigo, etc.).
  /// Único por conector, não globalmente.
  @override
  final String sourceId;

  /// Tipo MIME do conteúdo (ex.: 'text/markdown', 'text/html', 'application/pdf').
  @override
  final String contentType;

  /// Título/assunto do conteúdo.
  @override
  final String title;

  /// Autor, remetente ou criador do conteúdo (nullable — PDFs/emails podem não ter).
  @override
  final String? author;

  /// Conteúdo bruto: HTML, Markdown, texto plano, ou serialização de estrutura
  /// (ex.: JSON extraído de um webhook). Pode ser nulo para anexos.
  @override
  final String? rawContent;

  /// URL de origem (link do artigo, URL do email, etc.). Nullable.
  @override
  final String? url;

  /// Quando o conteúdo foi publicado/criado na origem.
  @override
  final DateTime capturedAt;

  /// Metadados adicionais específicos do conector, serializados como JSON.
  /// Exemplos: `{ "workItemId": "...", "tags": [...], "attachmentCount": 2 }`.
  @override
  final String? metadataJson;

  @override
  String toString() {
    return 'Document(id: $id, sourceConnectorId: $sourceConnectorId, sourceId: $sourceId, contentType: $contentType, title: $title, author: $author, rawContent: $rawContent, url: $url, capturedAt: $capturedAt, metadataJson: $metadataJson)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DocumentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sourceConnectorId, sourceConnectorId) ||
                other.sourceConnectorId == sourceConnectorId) &&
            (identical(other.sourceId, sourceId) ||
                other.sourceId == sourceId) &&
            (identical(other.contentType, contentType) ||
                other.contentType == contentType) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.rawContent, rawContent) ||
                other.rawContent == rawContent) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.capturedAt, capturedAt) ||
                other.capturedAt == capturedAt) &&
            (identical(other.metadataJson, metadataJson) ||
                other.metadataJson == metadataJson));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    sourceConnectorId,
    sourceId,
    contentType,
    title,
    author,
    rawContent,
    url,
    capturedAt,
    metadataJson,
  );

  /// Create a copy of Document
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DocumentImplCopyWith<_$DocumentImpl> get copyWith =>
      __$$DocumentImplCopyWithImpl<_$DocumentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DocumentImplToJson(this);
  }
}

abstract class _Document extends Document {
  const factory _Document({
    required final String id,
    required final String sourceConnectorId,
    required final String sourceId,
    required final String contentType,
    required final String title,
    final String? author,
    final String? rawContent,
    final String? url,
    required final DateTime capturedAt,
    final String? metadataJson,
  }) = _$DocumentImpl;
  const _Document._() : super._();

  factory _Document.fromJson(Map<String, dynamic> json) =
      _$DocumentImpl.fromJson;

  @override
  String get id;

  /// Identificador do conector que originou este documento.
  /// Exemplos: 'rss:the-old-reader', 'email:gmail', 'local-note'.
  @override
  String get sourceConnectorId;

  /// ID do documento na origem (UID de email, URL de artigo, etc.).
  /// Único por conector, não globalmente.
  @override
  String get sourceId;

  /// Tipo MIME do conteúdo (ex.: 'text/markdown', 'text/html', 'application/pdf').
  @override
  String get contentType;

  /// Título/assunto do conteúdo.
  @override
  String get title;

  /// Autor, remetente ou criador do conteúdo (nullable — PDFs/emails podem não ter).
  @override
  String? get author;

  /// Conteúdo bruto: HTML, Markdown, texto plano, ou serialização de estrutura
  /// (ex.: JSON extraído de um webhook). Pode ser nulo para anexos.
  @override
  String? get rawContent;

  /// URL de origem (link do artigo, URL do email, etc.). Nullable.
  @override
  String? get url;

  /// Quando o conteúdo foi publicado/criado na origem.
  @override
  DateTime get capturedAt;

  /// Metadados adicionais específicos do conector, serializados como JSON.
  /// Exemplos: `{ "workItemId": "...", "tags": [...], "attachmentCount": 2 }`.
  @override
  String? get metadataJson;

  /// Create a copy of Document
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DocumentImplCopyWith<_$DocumentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
