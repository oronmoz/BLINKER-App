import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vehicle_me/data/repositories/vehicle_services/vehicle_service_contract.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../domain/models/parking_location.dart';

class ParkingService extends IParkingService {
  final String baseURL;

  ParkingService(this.baseURL);

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<List<ParkingLocation>> fetchParkingLocations(LatLng location) async {
    try {
      final response = await http.get(Uri.parse(
          '$baseURL/maps/parking-locations/?lat=${location.latitude}&lon=${location.longitude}'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];
        return results
            .map<ParkingLocation>((parking) => ParkingLocation(
            placeId: parking['place_id'],
            address: parking['address'] ?? 'No address available',
            lat: parking['geometry']['location']['lat'],
            lon: parking['geometry']['location']['lng']))
            .toList();
      } else {
        throw Exception('Failed to load parking locations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching parking locations: $e');
    }
  }

  Future<void> launchMaps(double lat, double lon) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $uri';
    }
  }
}