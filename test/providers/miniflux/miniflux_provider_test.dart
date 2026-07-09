import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:feedflow/providers/miniflux/miniflux_provider.dart';
import 'package:feedflow/models/feed.dart';
import 'package:feedflow/models/article.dart';
import 'package:feedflow/providers/auth/auth_config.dart';

void main() {
  group('MinifluxProvider', () {
    group('getFeeds', () {
      test('parses successful feed list response correctly', () async {
        final mockResponse = [
          {
            'id': 1,
            'title': 'Tech News',
            'feed_url': 'https://example.com/feed.xml',
            'site_url': 'https://example.com',
            'category': {'id': 10, 'title': 'Technology'}
          },
          {
            'id': 2,
            'title': 'Sports Daily',
            'feed_url': 'https://sports.com/feed.xml',
            'site_url': 'https://sports.com',
            'category': {'id': 11, 'title': 'Sports'}
          },
        ];

        final client = MockClient((request) async {
          if (request.url.path.contains('/v1/feeds')) {
            return http.Response(jsonEncode(mockResponse), 200);
          }
          return http.Response('Not found', 404);
        });

        final provider = MinifluxProvider(client: client);

        final feeds = await provider.getFeeds();

        expect(feeds, isNotEmpty);
        expect(feeds.length, equals(2));
        expect(feeds[0].id, equals('1'));
        expect(feeds[0].title, equals('Tech News'));
        expect(feeds[0].url, equals('https://example.com/feed.xml'));
        expect(feeds[0].siteUrl, equals('https://example.com'));
        expect(feeds[0].categories, contains('Technology'));
        expect(feeds[1].id, equals('2'));
        expect(feeds[1].title, equals('Sports Daily'));
      });

      test('returns empty list on HTTP error', () async {
        final client = MockClient((request) async {
          return http.Response('Unauthorized', 401);
        });

        final provider = MinifluxProvider(client: client);

        final feeds = await provider.getFeeds();

        expect(feeds, isEmpty);
      });

      test('returns empty list on 500 error', () async {
        final client = MockClient((request) async {
          return http.Response('Internal Server Error', 500);
        });

        final provider = MinifluxProvider(client: client);

        final feeds = await provider.getFeeds();

        expect(feeds, isEmpty);
      });

      test('returns empty list on parse exception', () async {
        final client = MockClient((request) async {
          return http.Response('Invalid JSON', 200);
        });

        final provider = MinifluxProvider(client: client);

        final feeds = await provider.getFeeds();

        expect(feeds, isEmpty);
      });
    });

    group('getArticles', () {
      test('parses successful articles response correctly', () async {
        final mockResponse = {
          'entries': [
            {
              'id': 101,
              'title': 'Article 1',
              'content': 'Article content 1',
              'summary': 'Summary 1',
              'author': 'Author 1',
              'url': 'https://example.com/article1',
              'published_at': '2024-01-01T10:00:00Z',
              'feed_id': 1,
              'status': 'unread',
              'starred': false,
              'feed': {'id': 1, 'title': 'Tech News'}
            },
            {
              'id': 102,
              'title': 'Article 2',
              'content': 'Article content 2',
              'summary': 'Summary 2',
              'author': 'Author 2',
              'url': 'https://example.com/article2',
              'published_at': '2024-01-02T10:00:00Z',
              'feed_id': 1,
              'status': 'read',
              'starred': true,
              'feed': {'id': 1, 'title': 'Tech News'}
            },
          ],
          'total': 2
        };

        final client = MockClient((request) async {
          if (request.url.path.contains('/v1/feeds/') &&
              request.url.path.contains('/entries')) {
            return http.Response(jsonEncode(mockResponse), 200);
          }
          return http.Response('Not found', 404);
        });

        final provider = MinifluxProvider(client: client);

        final result = await provider.getArticles(streamId: '1');

        expect(result.articles, isNotEmpty);
        expect(result.articles.length, equals(2));
        expect(result.articles[0].id, equals('101'));
        expect(result.articles[0].title, equals('Article 1'));
        expect(result.articles[0].content, equals('Article content 1'));
        expect(result.articles[0].author, equals('Author 1'));
        expect(result.articles[0].isRead, isFalse);
        expect(result.articles[0].isStarred, isFalse);
        expect(result.articles[1].id, equals('102'));
        expect(result.articles[1].isRead, isTrue);
        expect(result.articles[1].isStarred, isTrue);
        expect(result.totalCount, equals(2));
      });

      test('returns empty list when articles response is not in expected format',
          () async {
        final client = MockClient((request) async {
          if (request.url.path.contains('/v1/feeds/') &&
              request.url.path.contains('/entries')) {
            // Return response without 'entries' key
            return http.Response(jsonEncode({'data': []}), 200);
          }
          return http.Response('Not found', 404);
        });

        final provider = MinifluxProvider(client: client);

        final result = await provider.getArticles(streamId: '1');

        expect(result.articles, isEmpty);
      });

      test('applies excludeRead filter in URL', () async {
        late String requestUrl;
        final client = MockClient((request) async {
          requestUrl = request.url.toString();
          if (request.url.path.contains('/v1/feeds/') &&
              request.url.path.contains('/entries')) {
            return http.Response(jsonEncode({'entries': [], 'total': 0}), 200);
          }
          return http.Response('Not found', 404);
        });

        final provider = MinifluxProvider(client: client);

        await provider.getArticles(streamId: '1', excludeRead: true);

        expect(requestUrl, contains('status=unread'));
      });
    });

    group('Feed with no category', () {
      test('handles feeds without category gracefully', () async {
        final mockResponse = [
          {
            'id': 1,
            'title': 'No Category Feed',
            'feed_url': 'https://example.com/feed.xml',
            'site_url': 'https://example.com',
            // No category field
          },
        ];

        final client = MockClient((request) async {
          if (request.url.path.contains('/v1/feeds')) {
            return http.Response(jsonEncode(mockResponse), 200);
          }
          return http.Response('Not found', 404);
        });

        final provider = MinifluxProvider(client: client);

        final feeds = await provider.getFeeds();

        expect(feeds, isNotEmpty);
        expect(feeds[0].categories, isEmpty);
      });
    });
  });
}
