import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vehicle_me/config.dart';
import '../../../domain/models/user.dart';
import '../../../domain/state_management/home/home_bloc.dart';

class MyCarPage extends StatefulWidget {
  final User user;
  final String last_test_date;
  final String test_expiration_date;
  final String on_road_date;

  MyCarPage({
    required this.user,
    required this.last_test_date,
    required this.test_expiration_date,
    required this.on_road_date,
  });

  @override
  _MyCarPageState createState() => _MyCarPageState();
}

class _MyCarPageState extends State<MyCarPage> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (exitRouteInfo) async {
        context.read<HomePageBloc>().add(HomeExit());
        Navigator.maybePop(context);
        return;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('More Info'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(
                icon: Icons.event_available,
                title: 'Last Vehicle Test',
                value: widget.last_test_date,
              ),
              _buildInfoCard(
                icon: Icons.event_busy,
                title: 'Test Expiration',
                value: widget.test_expiration_date,
              ),
              _buildInfoCard(
                icon: Icons.directions_car,
                title: 'On The Road Since',
                value: widget.on_road_date,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.blue),
        title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: TextStyle(fontSize: 16)),
      ),
    );
  }
}