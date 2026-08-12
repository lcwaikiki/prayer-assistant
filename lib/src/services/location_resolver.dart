import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../models/prayer_models.dart';

class DeviceLocationGuess {
  DeviceLocationGuess({
    required this.country,
    required this.state,
    required this.city,
    required this.district,
  });

  final String country;
  final String state;
  final String city;
  final String district;
}

class LocationResolver {
  final Geocoding _geocoding = Geocoding();

  Future<DeviceLocationGuess> resolveFromDevice() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location service is disabled on this device.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission is required.');
    }

    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    );
    final places = await _geocoding.placemarkFromCoordinates(
      pos.latitude,
      pos.longitude,
    );
    if (places.isEmpty) {
      throw Exception('Could not resolve location details from GPS.');
    }
    final p = places.first;
    return DeviceLocationGuess(
      country: (p.country ?? '').trim(),
      state: (p.administrativeArea ?? p.subAdministrativeArea ?? '').trim(),
      city: (p.locality ?? p.subLocality ?? p.subAdministrativeArea ?? '')
          .trim(),
      district: (p.subAdministrativeArea ?? p.locality ?? p.subLocality ?? '')
          .trim(),
    );
  }

  LocationNode? bestMatch(List<LocationNode> nodes, List<String> candidates) {
    if (nodes.isEmpty) {
      return null;
    }
    final normalizedCandidates = candidates
        .map(_normalize)
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    if (normalizedCandidates.isEmpty) {
      return null;
    }

    for (final candidate in normalizedCandidates) {
      for (final node in nodes) {
        final a = _normalize(node.name);
        final b = _normalize(node.englishName);
        if (a == candidate ||
            b == candidate ||
            a.contains(candidate) ||
            b.contains(candidate)) {
          return node;
        }
      }
    }
    return null;
  }

  String _normalize(String value) {
    final mapped = value
        .toLowerCase()
        .replaceAll('ç', 'c')
        .replaceAll('ğ', 'g')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ş', 's')
        .replaceAll('ü', 'u');
    return mapped.replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}
