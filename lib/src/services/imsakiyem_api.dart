import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/prayer_models.dart';

class ImsakiyemApi {
  static const _baseUrl = 'https://ezanvakti.imsakiyem.com/api';

  final http.Client _client = http.Client();

  Future<List<LocationNode>> getCountries() async {
    final response = await _get('/locations/countries');
    final data = response['data'] as List<dynamic>? ?? const <dynamic>[];
    return data
        .whereType<Map<String, dynamic>>()
        .map(LocationNode.fromJson)
        .toList(growable: false);
  }

  Future<List<LocationNode>> getStates(String countryId) async {
    final response = await _get('/locations/states?countryId=$countryId');
    final data = response['data'] as List<dynamic>? ?? const <dynamic>[];
    return data
        .whereType<Map<String, dynamic>>()
        .map(LocationNode.fromJson)
        .toList(growable: false);
  }

  Future<List<LocationNode>> getDistricts(String stateId) async {
    final response = await _get('/locations/districts?stateId=$stateId');
    final data = response['data'] as List<dynamic>? ?? const <dynamic>[];
    return data
        .whereType<Map<String, dynamic>>()
        .map(LocationNode.fromJson)
        .toList(growable: false);
  }

  Future<List<PrayerDay>> getYearlyPrayerTimes({
    required String districtId,
    required int year,
  }) async {
    final startDate = DateFormat('yyyy-MM-dd').format(DateTime(year, 1, 1));
    final response = await _get(
      '/prayer-times/$districtId/yearly?startDate=$startDate',
    );
    final data = response['data'] as List<dynamic>? ?? const <dynamic>[];
    return data
        .whereType<Map<String, dynamic>>()
        .map(PrayerDay.fromApi)
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    late final http.Response response;
    try {
      response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));
    } on SocketException catch (e) {
      throw Exception(
        'Could not reach prayer server. Check internet/DNS and try again. '
        'Details: ${e.message}',
      );
    } on HttpException catch (e) {
      throw Exception('Network HTTP error: ${e.message}');
    } on FormatException {
      throw Exception('Server response format is invalid.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }

    if (response.statusCode != 200) {
      throw Exception('Request failed (${response.statusCode}) for $path');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final success = payload['success'] == true;
    if (!success) {
      throw Exception(
        payload['message']?.toString() ?? 'API returned an error.',
      );
    }
    return payload;
  }
}
