import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../data/repositories/vehicle_services/locate_service.dart';
import 'locate_service_event.dart';
import 'locate_service_state.dart';

class LocateServicesBloc extends Bloc<LocateServicesEvent, LocateServicesState> {
  final LocateServicesAPI _api;

  LocateServicesBloc(this._api) : super(LocateServicesState()) {
    on<GetCurrentLocationEvent>(_onGetCurrentLocation);
    on<UpdateServiceTypeEvent>(_onUpdateServiceType);
    on<FetchServiceLocationsEvent>(_onFetchServiceLocations);
    on<LaunchMapsEvent>(_onLaunchMaps);
  }

  Future<void> _onGetCurrentLocation(GetCurrentLocationEvent event, Emitter<LocateServicesState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));
      final position = await _api.getCurrentLocation();
      add(FetchServiceLocationsEvent(position));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onFetchServiceLocations(FetchServiceLocationsEvent event, Emitter<LocateServicesState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));
      final serviceType = _getServiceTypeString(state.selectedServiceType);
      final locations = await _api.fetchServiceLocations(event.position, serviceType);
      final markers = _api.createMarkers(locations);
      emit(state.copyWith(
        isLoading: false,
        serviceLocations: locations,
        markers: markers,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onUpdateServiceType(UpdateServiceTypeEvent event, Emitter<LocateServicesState> emit) {
    emit(state.copyWith(selectedServiceType: event.serviceType));
    if (state.markers.isNotEmpty) {
      add(FetchServiceLocationsEvent(LatLng(
        state.markers.first.position.latitude,
        state.markers.first.position.longitude,
      )));
    }
  }

  Future<void> _onLaunchMaps(LaunchMapsEvent event, Emitter<LocateServicesState> emit) async {
    await _api.launchMaps(event.lat, event.lon);
  }

  String _getServiceTypeString(ServiceType type) {
    switch (type) {
      case ServiceType.CarGarages:
        return 'Car Garages';
      case ServiceType.GasStations:
        return 'Gas Stations';
      case ServiceType.CarWashes:
        return 'Car Washes';
    }
  }
}