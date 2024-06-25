import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../data/repositories/vehicle_services/vehicle_service_contract.dart';
import '../../../models/parking_location.dart';
import 'package:permission_handler/permission_handler.dart';

part 'parking_event.dart';
part 'parking_state.dart';

class ParkingBloc extends Bloc<ParkingEvent, ParkingState> {
  final IParkingService _parkingService;

  ParkingBloc(this._parkingService) : super(ParkingState(
    currentLocation: LatLng(0, 0),
    markers: {},
    parkingLocations: [],
    isLoading: false,
  )) {
    on<InitializeParking>(_onInitializeParking);
    on<MapCreated>(_onMapCreated);
    on<FetchParkingLocations>(_onFetchParkingLocations);
    on<ParkingSelected>(_onParkingSelected);
    on<LaunchMapsRequested>(_onLaunchMapsRequested);
    on<LocationPermissionDenied>(_onLocationPermissionDenied);
  }

  Future<void> _onInitializeParking(InitializeParking event, Emitter<ParkingState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final status = await Permission.location.request();
      if (status.isGranted) {
        final position = await _parkingService.getCurrentLocation();
        emit(state.copyWith(
          currentLocation: LatLng(position.latitude, position.longitude),
          isLoading: false,
        ));
        add(FetchParkingLocations());
      } else {
        add(LocationPermissionDenied());
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onMapCreated(MapCreated event, Emitter<ParkingState> emit) {
    emit(state.copyWith(mapController: event.controller));
  }

  Future<void> _onFetchParkingLocations(FetchParkingLocations event, Emitter<ParkingState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final parkingLocations = await _parkingService.fetchParkingLocations(state.currentLocation);
      final markers = parkingLocations.map((parking) => Marker(
        markerId: MarkerId(parking.placeId),
        position: LatLng(parking.lat, parking.lon),
        infoWindow: InfoWindow(
          title: parking.address,
          snippet: parking.address,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      )).toSet();
      emit(state.copyWith(
        parkingLocations: parkingLocations,
        markers: markers,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onParkingSelected(ParkingSelected event, Emitter<ParkingState> emit) {
    state.mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(event.parking.lat, event.parking.lon)));
  }

  Future<void> _onLaunchMapsRequested(LaunchMapsRequested event, Emitter<ParkingState> emit) async {
    try {
      await _parkingService.launchMaps(event.parking.lat, event.parking.lon);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onLocationPermissionDenied(LocationPermissionDenied event, Emitter<ParkingState> emit) {
    emit(state.copyWith(error: 'Location permission is required to use this feature.'));
  }
}