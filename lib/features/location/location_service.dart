import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  Future<String> getCurrentLocationAddress() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return 'Location permissions are permanently denied, we cannot request permissions.';
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Combine address components as seen in screenshot "n Institute of Technology Roorkee, Roorkee, Uttarakhand 247667"
        final street = place.street ?? place.name ?? "";
        final subLocality = place.subLocality ?? "";
        final locality = place.locality ?? "";
        final state = place.administrativeArea ?? "";
        final zip = place.postalCode ?? "";
        
        // Return formatted address. Since screenshot is partial, we make a robust attempt.
        List<String> parts = [
          if (street.isNotEmpty) street,
          if (subLocality.isNotEmpty && subLocality != street) subLocality,
        ];
        
        String line1 = parts.join(", ");
        String line2 = "$locality, $state $zip".trim();
        
        if (line1.isEmpty) {
            return line2;
        }
        return "$line1,\n$line2";
      }
      return "${position.latitude}, ${position.longitude}";
    } catch (e) {
       return "Error fetching location:\n$e";
    }
  }
}
