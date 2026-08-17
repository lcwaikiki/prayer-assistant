import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:prayer_assistant/src/services/imsakiyem_api.dart';

void main() {
  group('ImsakiyemApi', () {
    test('getCountries parses the data list', () async {
      final api = ImsakiyemApi(
        client: MockClient((request) async {
          expect(request.url.path, '/api/locations/countries');
          return http.Response(
            jsonEncode({
              'success': true,
              'data': [
                {'_id': 'tr', 'name': 'Türkiye', 'name_en': 'Turkey'},
                {'_id': 'sa', 'name': 'Suudi', 'name_en': 'Saudi Arabia'},
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      final countries = await api.getCountries();

      expect(countries, hasLength(2));
      expect(countries.first.id, 'tr');
      expect(countries.first.name, 'Türkiye');
      expect(countries.first.englishName, 'Turkey');
    });

    test('getStates sends the countryId query parameter', () async {
      final api = ImsakiyemApi(
        client: MockClient((request) async {
          expect(request.url.path, '/api/locations/states');
          expect(request.url.queryParameters['countryId'], 'tr');
          return http.Response(
            jsonEncode({'success': true, 'data': []}),
            200,
          );
        }),
      );

      final states = await api.getStates('tr');

      expect(states, isEmpty);
    });

    test('getDistricts sends the stateId query parameter', () async {
      final api = ImsakiyemApi(
        client: MockClient((request) async {
          expect(request.url.path, '/api/locations/districts');
          expect(request.url.queryParameters['stateId'], '34');
          return http.Response(
            jsonEncode({'success': true, 'data': []}),
            200,
          );
        }),
      );

      final districts = await api.getDistricts('34');

      expect(districts, isEmpty);
    });

    test('getYearlyPrayerTimes parses PrayerDay objects', () async {
      final api = ImsakiyemApi(
        client: MockClient((request) async {
          expect(request.url.path, '/api/prayer-times/541/yearly');
          expect(
            request.url.queryParameters['startDate'],
            '2026-01-01',
          );
          return http.Response(
            jsonEncode({
              'success': true,
              'data': [
                {
                  'date': '2026-01-01',
                  'times': {
                    'imsak': '06:20',
                    'gunes': '07:50',
                    'ogle': '12:20',
                    'ikindi': '14:40',
                    'aksam': '16:50',
                    'yatsi': '18:10',
                  },
                  'hijri_date': {'full_date': '12 Rajab 1447'},
                },
              ],
            }),
            200,
          );
        }),
      );

      final days = await api.getYearlyPrayerTimes(
        districtId: '541',
        year: 2026,
      );

      expect(days, hasLength(1));
      expect(days.first.imsak, '06:20');
      expect(days.first.hijriDate, '12 Rajab 1447');
    });

    test('returns an empty list for an empty data payload', () async {
      final api = ImsakiyemApi(
        client: MockClient((request) async {
          return http.Response(jsonEncode({'success': true, 'data': []}), 200);
        }),
      );

      expect(await api.getCountries(), isEmpty);
    });

    test('throws a friendly error when the server body is not JSON', () async {
      final api = ImsakiyemApi(
        client: MockClient((request) async {
          return http.Response('<html>error</html>', 200);
        }),
      );

      expect(
        () => api.getCountries(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('invalid'),
          ),
        ),
      );
    });

    test('throws for a non-200 status code', () async {
      final api = ImsakiyemApi(
        client: MockClient((request) async {
          return http.Response('{}', 500);
        }),
      );

      expect(
        () => api.getCountries(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('500'),
          ),
        ),
      );
    });

    test('throws the server message when success is false', () async {
      final api = ImsakiyemApi(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'success': false, 'message': 'District not found'}),
            200,
          );
        }),
      );

      expect(
        () => api.getCountries(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('District not found'),
          ),
        ),
      );
    });

    test('throws a friendly error on timeout', () async {
      final api = ImsakiyemApi(
        client: MockClient((request) async {
          throw TimeoutException('timed out');
        }),
      );

      expect(
        () => api.getCountries(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('timed out'),
          ),
        ),
      );
    });

    test('throws a friendly error on malformed JSON in a 200 response',
        () async {
      final api = ImsakiyemApi(
        client: MockClient((request) async {
          return http.Response('not-json', 200);
        }),
      );

      expect(
        () => api.getCountries(),
        throwsA(isA<Exception>()),
      );
    });

    test('coerces raw non-map entries out of the data list', () async {
      final api = ImsakiyemApi(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': [
                'garbage',
                {'_id': 'tr', 'name': 'Türkiye', 'name_en': 'Turkey'},
              ],
            }),
            200,
          );
        }),
      );

      final countries = await api.getCountries();

      expect(countries, hasLength(1));
      expect(countries.single.id, 'tr');
    });
  });
}