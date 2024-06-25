part of 'parking_bloc.dart';

abstract class ParkingEvent extends Equatable {}

class InitializeParking extends ParkingEvent {
  @override
  List<Object?> get props => [];
}

class MapCreated extends ParkingEvent {
  final GoogleMapController controller;
  MapCreated(this.controller);

  @override
  List<Object?> get props => [controller];
}

class FetchParkingLocations extends ParkingEvent {
  @override
  List<Object?> get props => [];
}

class ParkingSelected extends ParkingEvent {
  final ParkingLocation parking;
  ParkingSelected(this.parking);

  @override
  List<Object?> get props => [parking];
}

class LaunchMapsRequested extends ParkingEvent {
  final ParkingLocation parking;
  LaunchMapsRequested(this.parking);

  @override
  List<Object?> get props => [parking];
}

class LocationPermissionDenied extends ParkingEvent {
  @override
  List<Object?> get props => [];
}