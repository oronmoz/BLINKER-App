import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../domain/models/parking_location.dart';


abstract class IParkingService{
  Future<List<ParkingLocation>> fetchParkingLocations(LatLng location);

  Future<Position> getCurrentLocation();

  Future<void> launchMaps(double lat, double lon);
}