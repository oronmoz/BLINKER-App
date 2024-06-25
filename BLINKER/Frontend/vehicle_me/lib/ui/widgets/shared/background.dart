import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:vehicle_me/themes.dart';

class InfinitePatternBackground extends StatelessWidget {
  const InfinitePatternBackground();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [
          // Background container with the image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  isLightTheme(context)
                      ? 'assets/images/light_pattern_image.png'
                      : 'assets/images/dark_pattern_image.png',
                ),
                fit: BoxFit.cover, // Ensure the image covers the entire screen
              ),
            ),
          ),
          // Positioned widget to create the infinite pattern effect
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    isLightTheme(context)
                        ? 'assets/images/light_pattern_image.png'
                        : 'assets/images/dark_pattern_image.png',
                  ),
                  fit: BoxFit.none, // Ensure the image doesn't stretch
                  repeat: ImageRepeat.repeat, // Repeat the image infinitely
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
