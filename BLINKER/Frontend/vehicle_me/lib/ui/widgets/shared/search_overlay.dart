import 'package:flutter/material.dart';
import 'package:animations/animations.dart'; // Import animations package
import 'custom_text_field.dart'; // Adjust path as needed

class SearchOverlay extends StatefulWidget {
  @override
  _SearchOverlayState createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                hint: 'Search',
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}