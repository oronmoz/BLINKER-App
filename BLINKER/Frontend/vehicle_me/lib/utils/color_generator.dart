import 'dart:math';

import 'package:flutter/material.dart';

class RandomColorGenerator {
  static final Random random = Random();

  static Color getColor() {
    return Color.fromARGB(
        255,
        random.nextInt(255),
        random.nextInt(255),
        random.nextInt(255)
    );
  }

  // Add a method to generate a color based on input
  static Color getColorForUser(dynamic message, dynamic user) {
    // Use some properties from message and user to seed the random generator
    // This ensures the same user gets the same color consistently
    final seed = message.hashCode ^ user.hashCode;
    final seededRandom = Random(seed);

    return Color.fromARGB(
        255,
        seededRandom.nextInt(255),
        seededRandom.nextInt(255),
        seededRandom.nextInt(255)
    );
  }
}
