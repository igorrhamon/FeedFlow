import 'package:freezed_annotation/freezed_annotation.dart';

part 'article.freezed.dart';
part 'article.g.dart';

@freezed
class Article with _$Article {
  const factory Article({
    required String id,
    required String feedId,
    required String title,
    String? author,
    String? summary,
    String? content,
    String? url,
    DateTime? published,
    DateTime? updated,
    @Default([]) List<String> categories,
    @Default(false) bool isRead,
    @Default(false) bool isStarred,
    @Default({}) Map<String, dynamic> metadata,
  }) = _Article;

  factory Article.fromJson(Map<String, dynamic> json) => _$ArticleFromJson(json);
}

@freezed
class ArticleListResult with _$ArticleListResult {
  const factory ArticleListResult({
    required List<Article> articles,
    String? continuation,
    int? totalCount,
  }) = _ArticleListResult;

  factory ArticleListResult.fromJson(Map<String, dynamic> json) => _$ArticleListResultFromJson(json);
}