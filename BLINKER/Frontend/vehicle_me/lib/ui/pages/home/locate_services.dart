import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../data/repositories/vehicle_services/locate_service.dart';
import '../../../domain/state_management/home/vehicle_services/locate_service_bloc.dart';
import '../../../domain/state_management/home/vehicle_services/locate_service_event.dart';
import '../../../domain/state_management/home/vehicle_services/locate_service_state.dart';
import '../../../domain/state_management/home/home_bloc.dart'; // Assuming you have a HomeBloc

class LocateServicesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocateServicesBloc(LocateServicesAPI())..add(GetCurrentLocationEvent()),
      child: _LocateServicesView(),
    );
  }
}

class _LocateServicesView extends StatefulWidget {
  @override
  _LocateServicesViewState createState() => _LocateServicesViewState();
}

class _LocateServicesViewState extends State<_LocateServicesView> {
  late GoogleMapController _mapController;

  void _onServiceSelected(Map<String, dynamic> service) {
    _mapController.animateCamera(CameraUpdate.newLatLng(LatLng(service['lat'], service['lon'])));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          // The pop has already been handled, no need to do anything
          return;
        }
        context.read<HomePageBloc>().add(HomeExit());
        Navigator.pop(context);
      },
      child: BlocConsumer<LocateServicesBloc, LocateServicesState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Locate Vehicle Services'),
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<ServiceType>(
                    value: state.selectedServiceType,
                    items: ServiceType.values.map((ServiceType value) {
                      return DropdownMenuItem<ServiceType>(
                        value: value,
                        child: Text(value.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (ServiceType? newValue) {
                      if (newValue != null) {
                        context.read<LocateServicesBloc>().add(UpdateServiceTypeEvent(newValue));
                      }
                    },
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: state.markers.isNotEmpty
                      ? GoogleMap(
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    initialCameraPosition: CameraPosition(
                      target: state.markers.first.position,
                      zoom: 15.0,
                    ),
                    markers: Set.from(state.markers),
                  )
                      : Center(child: CircularProgressIndicator()),
                ),
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    itemCount: state.serviceLocations.length,
                    itemBuilder: (context, index) {
                      final service = state.serviceLocations[index];
                      return ListTile(
                        title: Text(service['address']),
                        subtitle: Text('Rating: ${service['rating']}'),
                        onTap: () => _onServiceSelected(service),
                        trailing: IconButton(
                          icon: Icon(Icons.directions),
                          onPressed: () => context.read<LocateServicesBloc>().add(LaunchMapsEvent(service['lat'], service['lon'])),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => context.read<LocateServicesBloc>().add(GetCurrentLocationEvent()),
              child: Icon(Icons.refresh),
            ),
          );
        },
      ),
    );
  }
}