import 'package:flutter/material.dart';

import 'online_indicator.dart';

class ProfileImage extends StatelessWidget {
  final String imageUrl;
  final bool online;
  const ProfileImage({required this.imageUrl, this.online=false});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: _buildImage(),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: online ? OnlineIndicator() : Container(),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl.isEmpty) {
      // If imageUrl is empty, use the local asset image
      return Image.asset(
        'assets/images/profile_photo.jpg',
        height: 126.0,
        width: 126.0,
        fit: BoxFit.fill,
      );
    } else {
      // Try to load the image from the network, fallback to local asset on error
      return Image.network(
        imageUrl,
        height: 126.0,
        width: 126.0,
        fit: BoxFit.fill,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/profile_image.png',
            height: 126.0,
            width: 126.0,
            fit: BoxFit.fill,
          );
        },
      );
    }
  }
}