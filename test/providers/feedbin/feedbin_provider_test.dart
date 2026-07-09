import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:feedflow/providers/feedbin/feedbin_provider.dart';
import 'package:feedflow/models/feed.dart';
import 'package:feedflow/models/article.dart';
import 'package:feedflow/providers/auth/auth_config.dart';

void main() {
  group('FeedbinProvider', () {
    group('getFeeds', () {
      test('parses successful subscriptions response correctly', () async {
        final mockResponse = [
          {
            'feed_id': 1001,
            'title': 'Tech News Feed',
            'feed_url': 'https://technews.example.com/feed.xml',
            'site_url': 'https://technews.example.com',
          },
          {
            'feed_id': 1002,
            'title': 'Science Daily',
            'feed_url': 'https://science.example.com/feed.xml',
            'site_url': 'https://science.example.com',
          },
        ];

        final client = MockClient((request) async {
          if (request.url.path.contains('/subscriptions.json')) {
            return http.Response(jsonEncode(mockResponse), 200);
          }
          return http.Response('Not found', 404);
        });

        final provider = FeedbinProvider(client: client);

        final feeds = await provider.getFeeds();

        expect(feeds, isNotEmpty);
        expect(feeds.length, equals(2));
        expect(feeds[0].id, equals('1001'));
        expect(feeds[0].title, equals('Tech News Feed'));
        expect(feeds[0].url, equals('https://technews.example.com/feed.xml'));
        expect(feeds[0].siteUrl, equals('https://technews.example.com'));
        expect(feeds[1].id, equals('1002'));
        expect(feeds[1].title, equals('Science Daily'));
      });

      test('returns empty list on HTTP 401 error', () async {
        final client = MockClient((request) async {
          return http.Response('Unauthorized', 401);
        });

        final provider = FeedbinProvider(client: client);

        final feeds = await provider.getFeeds();

        expect(feeds, isEmpty);
      });

      test('returns empty list on HTTP 500 error', () async {
        final client = MockClient((request) async {
          return http.Response('Internal Server Error', 500);
        });

        final provider = FeedbinProvider(client: client);

        final feeds = await provider.getFeeds();

        expect(feeds, isEmpty);
      });

      test('returns empty list when response is not a list', () async {
        final client = MockClient((request) async {
          if (request.url.path.contains('/subscriptions.json')) {
            // Return a map instead of list
            return http.Response(
                jsonEncode({'feeds': []}), 200);
          }
          return http.Response('Not found', 404);
        });

        final provider = FeedbinProvider(client: client);

        final feeds = await provider.getFeeds();

        expect(feeds, isEmpty);
      });

      test('returns empty list on parse exception', () async {
        final client = MockClient((request) async {
          if (request.url.path.contains('/subscriptions.json')) {
            return http.Response('Invalid JSON', 200);
          }
          return http.Response('Not found', 404);
        });

        final provider = FeedbinProvider(client: client);

        final feeds = await provider.getFeeds();

        expect(feeds, isEmpty);
      });
    });

    group('getArticles', () {
      test('parses successful entries response correctly', () async {
        final mockResponse = [
          {
            'id': 5001,
            'title': 'Article One',
            'content': 'Full article content one',
            'summary': 'Summary of article one',
            'author': 'John Doe',
            'url': 'https://example.com/article1',
            'published': '2024-01-01T10:00:00Z',
            'feed_id': 1001,
            'unread': true,
          },
          {
            'id': 5002,
            'title': 'Article Two',
            'content': 'Full article content two',
            'summary': 'Summary of article two',
            'author': 'Jane Smith',
            'url': 'https://example.com/article2',
            'published': '2024-01-02T10:00:00Z',
            'feed_id': 1001,
            'unread': false,
          },
        ];

        final client = MockClient((request) async {
          if (request.url.path.contains('/entries.json')) {
            return http.Response(jsonEncode(mockResponse), 200);
          }
          return http.Response('Not found', 404);
        });

        final provider = FeedbinProvider(client: client);

        final result = await provider.getArticles(streamId: '1001');

        expect(result.articles, isNotEmpty);
        expect(result.articles.length, equals(2));
        expect(result.articles[0].id, equals('5001'));
        expect(result.articles[0].title, equals('Article One'));
        expect(result.articles[0].content, equals('Full article content one'));
        expect(result.articles[0].summary, equals('Summary of article one'));
        expect(result.articles[0].author, equals('John Doe'));
        expect(result.articles[0].isRead, isFalse); // unread: true means isRead: false
        expect(result.articles[1].id, equals('5002'));
        expect(result.articles[1].isRead, isTrue); // unread: false means isRead: true
      });

      test('returns empty list on HTTP error', () async {
        final client = MockClient((request) async {
          return http.Response('Unauthorized', 401);
        });

        final provider = FeedbinProvider(client: client);

        final result = await provider.getArticles(streamId: '1001');

        expect(result.articles, isEmpty);
      });

      test('applies unread filter in URL', () async {
        late String requestUrl;
        final client = MockClient((request) async {
          requestUrl = request.url.toString();
          if (request.url.path.contains('/entries.json')) {
            return http.Response(jsonEncode([]), 200);
          }
          return http.Response('Not found', 404);
        });

        final provider = FeedbinProvider(client: client);

        await provider.getArticles(streamId: '1001', excludeRead: true);

        expect(requestUrl, contains('unread=true'));
      });

      test('returns empty list when response is not a list', () async {
        final client = MockClient((request) async {
          if (request.url.path.contains('/entries.json')) {
            // Return a map instead of list
            return http.Response(
                jsonEncode({'entries': []}), 200);
          }
          return http.Response('Not found', 404);
        });

        final provider = FeedbinProvider(client: client);

        final result = await provider.getArticles(streamId: '1001');

        expect(result.articles, isEmpty);
      });
    });

    group('getUnreadCounts', () {
      test('parses unread count response correctly', () async {
        final mockResponse = [
          {'feed_id': 1001, 'count': 5},
          {'feed_id': 1002, 'count': 12},
        ];

        final client = MockClient((request) async {
          if (request.url.path.contains('/unread_count.json')) {
            return http.Response(jsonEncode(mockResponse), 200);
          }
          return http.Response('Not found', 404);
        });

        final provider = FeedbinProvider(client: client);

        final counts = await provider.getUnreadCounts();

        expect(counts, isNotEmpty);
        expect(counts['1001'], equals(5));
        expect(counts['1002'], equals(12));
      });

      test('returns empty map on HTTP error', () async {
        final client = MockClient((request) async {
          return http.Response('Unauthorized', 401);
        });

        final provider = FeedbinProvider(client: client);

        final counts = await provider.getUnreadCounts();

        expect(counts, isEmpty);
      });
    });

    group('Feed with minimal data', () {
      test('handles feeds with missing optional fields', () async {
        final mockResponse = [
          {
            'feed_id': 1001,
            'title': 'Minimal Feed',
            // Missing feed_url and site_url
          },
        ];

        final client = MockClient((request) async {
          if (request.url.path.contains('/subscriptions.json')) {
            return http.Response(jsonEncode(mockResponse), 200);
          }
          return http.Response('Not found', 404);
        });

        final provider = FeedbinProvider(client: client);

        final feeds = await provider.getFeeds();

        expect(feeds, isNotEmpty);
        expect(feeds[0].id, equals('1001'));
        expect(feeds[0].title, equals('Minimal Feed'));
        expect(feeds[0].url, isNull);
        expect(feeds[0].siteUrl, isNull);
      });
    });
  });
}
