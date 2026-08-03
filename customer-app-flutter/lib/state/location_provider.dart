import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider extends ChangeNotifier {
  double? latitude;
  double? longitude;
  String? errorMessage;
  bool isLoading = false;

  Future<void> loadCurrentLocation() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        errorMessage = "Joylashuv xizmati o'chirilgan";
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        errorMessage = "Joylashuvga ruxsat berilmadi";
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      latitude = position.latitude;
      longitude = position.longitude;
    } catch (_) {
      errorMessage = "Joylashuvni aniqlab bo'lmadi";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Toshkent markazi — joylashuv aniqlanmagan holatlar uchun standart qiymat
  double get effectiveLatitude => latitude ?? 41.311081;
  double get effectiveLongitude => longitude ?? 69.240562;
}
