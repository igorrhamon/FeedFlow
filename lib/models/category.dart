import 'package:freezed_annotation/freezed_annotation.dart';
import 'feed.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    @Default(0) int unreadCount,
    @Default([]) List<Feed> feeds,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
}

@freezed
class UnreadCount with _$UnreadCount {
  const factory UnreadCount({
    required String id,
    required int count,
    DateTime? updated,
  }) = _UnreadCount;

  factory UnreadCount.fromJson(Map<String, dynamic> json) => _$UnreadCountFromJson(json);
}