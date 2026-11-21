import 'package:geolocator/geolocator.dart';
import 'database_helper.dart';

class LocationService {
  /// Cek apakah GPS aktif
  static Future<bool> isServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Cek status izin lokasi saat ini
  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Minta izin lokasi
  static Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Buka pengaturan aplikasi (untuk izin permanen)
  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Buka pengaturan lokasi (jika GPS mati)
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Dapatkan posisi pengguna saat ini
  static Future<Position?> getCurrentPosition() async {
    final serviceEnabled = await isServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    var permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (_) {
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  /// Hitung jarak (dalam kilometer) antara dua koordinat
  static double calculateDistanceKm({
    required double startLatitude,
    required double startLongitude,
    double? endLatitude,
    double? endLongitude,
  }) {
    final destLat = endLatitude ?? DatabaseHelper.storeLatitude;
    final destLng = endLongitude ?? DatabaseHelper.storeLongitude;

    final distanceInMeters = Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      destLat,
      destLng,
    );

    return distanceInMeters / 1000.0;
  }

  /// Hitung ongkos kirim sesuai aturan BR-06
  /// Jarak <= 5 km = Rp 5.000;
  /// > 5 km = Rp 5.000 + Rp 1.500 per km (dibulatkan ke atas), maks Rp 25.000;
  /// Jika lokasi tidak tersedia = flat Rp 10.000;
  /// Gratis ongkir jika subtotal >= Rp 200.000.
  static double calculateShippingCost({
    double? distanceKm,
    required double subtotal,
  }) {
    if (subtotal >= DatabaseHelper.freeShippingThreshold) {
      return 0.0; // Gratis ongkir
    }

    if (distanceKm == null || distanceKm < 0) {
      return DatabaseHelper.flatShippingCost; // Lokasi tidak tersedia
    }

    if (distanceKm <= DatabaseHelper.baseDistanceKm) {
      return DatabaseHelper.baseShippingCost;
    }

    final extraKm = (distanceKm - DatabaseHelper.baseDistanceKm).ceil();
    final totalCost = DatabaseHelper.baseShippingCost + (extraKm * DatabaseHelper.perKmShippingCost);

    if (totalCost > DatabaseHelper.maxShippingCost) {
      return DatabaseHelper.maxShippingCost;
    }

    return totalCost;
  }
}
