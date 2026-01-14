// Stubbed location service - replace with geolocator later
class LocationService {
  Future<String> getCurrentLocationName() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return "Pune, Maharashtra";
  }
}
