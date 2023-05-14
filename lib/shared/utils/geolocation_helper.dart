import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as permHandler;
import 'package:shared_preferences/shared_preferences.dart';

Future<permHandler.PermissionStatus?> requestLocationPermission() async {
  Map<permHandler.Permission, permHandler.PermissionStatus> statuses = await [
    permHandler.Permission.location,
  ].request();

  return statuses[permHandler.Permission.location];
}

Future<Coordinates> getCoordinates() async {
  bool serviceEnabled;
  LocationPermission permission;

  if (await requestLocationPermission() !=
      permHandler.PermissionStatus.granted) {
    return Future.error('Location permissions are denied');
  }

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  final locationData = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);

  final coordinates =
      Coordinates(locationData.latitude, locationData.longitude);

  saveCoordinates(coordinates);

  return coordinates;
}

Future<void> saveCoordinates(Coordinates coord) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setDouble('latitude', coord.latitude);
  await prefs.setDouble('longitude', coord.longitude);
}

Future<Coordinates> getSavedCoordinates() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('latitude') && prefs.containsKey('longitude')) {
    return Coordinates(
        prefs.getDouble('latitude')!, prefs.getDouble('longitude')!);
  }

  return Coordinates(0, 0);
}
