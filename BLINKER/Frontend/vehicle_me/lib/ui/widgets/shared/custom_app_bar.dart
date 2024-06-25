import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final bool isLightTheme;
  final ValueChanged<bool> onThemeChanged;

  CustomAppBar({
    required this.title,
    required this.backgroundColor,
    required this.isLightTheme,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
      // Add action for user profile button
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
      // Add action for settings button
            },
          ),
          Switch(
            value: isLightTheme,
            onChanged: onThemeChanged,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}