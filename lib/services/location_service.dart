import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Map<String, dynamic>> getCurrentLocation() async {
    if (kIsWeb) {
      // WEB fallback (temporary)
      return {
        'city': 'Pune',
        'state': 'Maharashtra',
        'latitude': 18.5204,
        'longitude': 73.8567,
      };
    }

    // MOBILE GPS
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return {
      'city': 'Unknown',
      'state': 'Unknown',
      'latitude': position.latitude,
      'longitude': position.longitude,
    };
  }
}
