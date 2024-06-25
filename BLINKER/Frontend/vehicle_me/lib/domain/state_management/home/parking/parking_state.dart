part of 'parking_bloc.dart';

// State
class ParkingState extends Equatable {
  final LatLng currentLocation;
  final Set<Marker> markers;
  final List<ParkingLocation> parkingLocations;
  final GoogleMapController? mapController;
  final bool isLoading;
  final String? error;

  const ParkingState({
    required this.currentLocation,
    required this.markers,
    required this.parkingLocations,
    this.mapController,
    this.isLoading = false,
    this.error,
  });

  ParkingState copyWith({
    LatLng? currentLocation,
    Set<Marker>? markers,
    List<ParkingLocation>? parkingLocations,
    GoogleMapController? mapController,
    bool? isLoading,
    String? error,
  }) {
    return ParkingState(
      currentLocation: currentLocation ?? this.currentLocation,
      markers: markers ?? this.markers,
      parkingLocations: parkingLocations ?? this.parkingLocations,
      mapController: mapController ?? this.mapController,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [currentLocation, markers, parkingLocations, mapController, isLoading, error];
}