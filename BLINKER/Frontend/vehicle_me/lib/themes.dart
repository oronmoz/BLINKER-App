import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

// Background decoration function
BoxDecoration getBackgroundDecoration() {
  return BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/your_map_image.png'),
      repeat: ImageRepeat.repeat,
    ),
  );
}

// Custom ThemeExtension for background
class BackgroundTheme extends ThemeExtension<BackgroundTheme> {
  final BoxDecoration? decoration;

  const BackgroundTheme({this.decoration});

  @override
  ThemeExtension<BackgroundTheme> copyWith({BoxDecoration? decoration}) {
    return BackgroundTheme(
      decoration: decoration ?? this.decoration,
    );
  }

  @override
  ThemeExtension<BackgroundTheme> lerp(
      ThemeExtension<BackgroundTheme>? other, double t) {
    if (other is! BackgroundTheme) {
      return this;
    }
    return BackgroundTheme(
      decoration: BoxDecoration.lerp(decoration, other.decoration, t),
    );
  }
}

final appBarTheme = AppBarTheme(
  centerTitle: false,
  elevation: 0,
  backgroundColor: Colors.transparent,
);

final tabBarTheme = TabBarTheme(
  indicatorSize: TabBarIndicatorSize.label,
  unselectedLabelColor: kLightBlueGrayDM,
  indicator: BoxDecoration(
    borderRadius: BorderRadius.circular(50),
    color: kPurpleBlueDM,
  ),
);

final dividerTheme =
    const DividerThemeData().copyWith(thickness: 1.0, indent: 75.0);

ThemeData lightMode(BuildContext context) => ThemeData.light().copyWith(
      primaryColor: kCreamLM,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        color: kDarkGrayDM,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: kPurpleBlueDM,
        unselectedLabelColor: Colors.black54,
      ),
      dividerTheme: DividerThemeData(
        color: kLightBlueGrayDM,
      ),
      iconTheme: IconThemeData(color: kGrayLM),
      textTheme: GoogleFonts.comfortaaTextTheme(Theme.of(context).textTheme)
          .apply(displayColor: Colors.black),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

ThemeData darkMode(BuildContext context) => ThemeData.dark().copyWith(
    primaryColor: kDarkGrayDM,
    scaffoldBackgroundColor: Colors.transparent,
    tabBarTheme: tabBarTheme.copyWith(unselectedLabelColor: kDarkGreenDM),
    appBarTheme: appBarTheme.copyWith(backgroundColor: Colors.transparent),
    dividerTheme: dividerTheme.copyWith(color: kLightBlueGrayDM),
    iconTheme: IconThemeData(color: Colors.black),
    textTheme: GoogleFonts.comfortaaTextTheme(Theme.of(context).textTheme)
        .apply(displayColor: Colors.white),
    visualDensity: VisualDensity.adaptivePlatformDensity);

bool isLightTheme(BuildContext context) {
  return MediaQuery.of(context).platformBrightness == Brightness.light;
}
