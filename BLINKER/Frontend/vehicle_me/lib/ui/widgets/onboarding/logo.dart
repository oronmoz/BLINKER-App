import 'package:flutter/material.dart';
import '../../../themes.dart';

class Logo extends StatelessWidget {
  const Logo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 0.0),
        child: SizedBox( // Wrap with SizedBox to set constraints
          width: 250, // Set a suitable width
          height: 250, // Set a suitable height
          child: isLightTheme(context)
              ? Image.asset(
            'assets/images/blinker_LG3.png',
            fit: BoxFit.contain, // Adjust the fit as necessary
          )
              : Image.asset(
            'assets/images/blinker_LG3_DarkMode.png',
            fit: BoxFit.contain, // Adjust the fit as necessary
          ),
        ),
      ),
    );
  }
}
