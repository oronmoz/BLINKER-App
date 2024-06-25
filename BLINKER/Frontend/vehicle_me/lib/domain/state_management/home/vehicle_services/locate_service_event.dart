import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'locate_service_state.dart';

// Events
abstract class LocateServicesEvent {}

class GetCurrentLocationEvent extends LocateServicesEvent {}

class UpdateServiceTypeEvent extends LocateServicesEvent {
  final ServiceType serviceType;
  UpdateServiceTypeEvent(this.serviceType);
}

class FetchServiceLocationsEvent extends LocateServicesEvent {
  final LatLng position;
  FetchServiceLocationsEvent(this.position);
}

class LaunchMapsEvent extends LocateServicesEvent {
  final double lat;
  final double lon;
  LaunchMapsEvent(this.lat, this.lon);
}