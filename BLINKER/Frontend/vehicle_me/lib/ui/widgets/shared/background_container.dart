import 'package:flutter/material.dart';

import '../../../themes.dart';

class BackgroundContainer extends StatelessWidget {
  final Widget child;

  const BackgroundContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: isLightTheme(context) ? AssetImage('assets/images/blinker_patternLM.png') : AssetImage('assets/images/blinker_patternDM.png'),
          repeat: ImageRepeat.repeat,

        ),
      ),
      child: child,
    );
  }
}