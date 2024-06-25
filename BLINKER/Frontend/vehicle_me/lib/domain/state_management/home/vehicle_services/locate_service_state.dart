import 'package:google_maps_flutter/google_maps_flutter.dart';

enum ServiceType { CarGarages, GasStations, CarWashes }

class LocateServicesState {
  final bool isLoading;
  final List<Map<String, dynamic>> serviceLocations;
  final List<Marker> markers;
  final ServiceType selectedServiceType;
  final String? error;

  LocateServicesState({
    this.isLoading = false,
    this.serviceLocations = const [],
    this.markers = const [],
    this.selectedServiceType = ServiceType.CarGarages,
    this.error,
  });

  LocateServicesState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? serviceLocations,
    List<Marker>? markers,
    ServiceType? selectedServiceType,
    String? error,
  }) {
    return LocateServicesState(
      isLoading: isLoading ?? this.isLoading,
      serviceLocations: serviceLocations ?? this.serviceLocations,
      markers: markers ?? this.markers,
      selectedServiceType: selectedServiceType ?? this.selectedServiceType,
      error: error,
    );
  }
}