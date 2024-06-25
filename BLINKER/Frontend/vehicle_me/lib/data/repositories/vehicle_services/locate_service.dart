import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:vehicle_me/config.dart';

class LocateServicesAPI {

  Future<LatLng> getCurrentLocation() async {
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

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return LatLng(position.latitude, position.longitude);
  }

  Future<List<Map<String, dynamic>>> fetchServiceLocations(LatLng position, String serviceType) async {
    // Ensure the baseURL includes the scheme and host
    if (!baseURL.startsWith('http://') && !baseURL.startsWith('https://')) {
      throw Exception('Invalid baseURL: missing scheme (http or https)');
    }

    final baseUri = Uri.parse(baseURL);

    // Construct the full URL
    final url = Uri(
      scheme: baseUri.scheme,
      host: baseUri.host,
      port: baseUri.port,
      path: '/maps/service-locations/',
      queryParameters: {
        'lat': position.latitude.toString(),
        'lon': position.longitude.toString(),
        'type': serviceType,
      },
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];
        return results.map<Map<String, dynamic>>((service) => {
          'placeId': service['place_id'],
          'address': service['address'] ?? 'No address available',
          'rating': service['rating']?.toString() ?? 'No rating',
          'lat': service['geometry']['location']['lat'],
          'lon': service['geometry']['location']['lng']
        }).toList();
      } else {
        throw Exception('Failed to load service locations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching service locations: $e');
    }
  }

  List<Marker> createMarkers(List<Map<String, dynamic>> locations) {
    return locations.map<Marker>((service) {
      return Marker(
        markerId: MarkerId(service['placeId']),
        position: LatLng(service['lat'], service['lon']),
        infoWindow: InfoWindow(
          title: service['address'],
          snippet: 'Rating: ${service['rating']}',
          onTap: () => launchMaps(service['lat'], service['lon']),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
    }).toList();
  }

  Future<void> launchMaps(double lat, double lon) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
    var uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }
}