import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../domain/state_management/home/parking/parking_bloc.dart';

class ParkingPage extends StatefulWidget {
  @override
  _ParkingPageState createState() => _ParkingPageState();
}


class _ParkingPageState extends State<ParkingPage> {
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }
  Future<void> _checkPermissions() async {
    // Use a permissions library like permission_handler
    // to check and request location permissions
    // If permissions are granted, initialize the parking feature
    context.read<ParkingBloc>().add(InitializeParking());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Locate Parking'),
      ),
      body: BlocConsumer<ParkingBloc, ParkingState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              Expanded(
                flex: 3,
                child: _buildMap(context),
              ),
              Expanded(
                flex: 2,
                child: _buildParkingList(context),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.read<ParkingBloc>().add(FetchParkingLocations()),
        child: Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildMap(BuildContext context) {
    final state = context.watch<ParkingBloc>().state;
    return GoogleMap(
      onMapCreated: (controller) {
        context.read<ParkingBloc>().add(MapCreated(controller));
      },
      initialCameraPosition: CameraPosition(
        target: state.currentLocation,
        zoom: 15.0,
      ),
      markers: state.markers,
      myLocationEnabled: true,  // This might cause the error if permissions aren't granted
      myLocationButtonEnabled: true,
    );
  }

  Widget _buildParkingList(BuildContext context) {
    final state = context.watch<ParkingBloc>().state;
    if (state.parkingLocations.isEmpty) {
      return Center(child: Text('No parking locations found'));
    }
    return ListView.builder(
      itemCount: state.parkingLocations.length,
      itemBuilder: (context, index) {
        final parking = state.parkingLocations[index];
        return ListTile(
          title: Text(parking.address),
          onTap: () => context.read<ParkingBloc>().add(ParkingSelected(parking)),
          trailing: IconButton(
            icon: Icon(Icons.directions),
            onPressed: () => context.read<ParkingBloc>().add(LaunchMapsRequested(parking)),
          ),
        );
      },
    );
  }
}