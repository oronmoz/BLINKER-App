import 'package:flutter/material.dart';

import '../../../colors.dart';
import '../../../themes.dart';

class CustomTextField extends StatelessWidget {
  final String? hint;
  final Function(String val)? onChanged;
  final double? height;
  final TextInputAction? inputAction;

  const CustomTextField(
      {this.hint, this.onChanged, this.height = 54, this.inputAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        keyboardType: TextInputType.text,
        onChanged: onChanged,
        textInputAction: inputAction,
        cursorColor: kDarkGrayDM,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.all(20),
            hintText: (hint),
            border: InputBorder.none),

      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(45.0),
          color: isLightTheme(context) ? Colors.white : Colors.black45,
          border: Border.all(
            color: isLightTheme(context) ? kDarkGreenDM : Colors.black54,
            width: 1.5,
          )),
    );
  }

}
