import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vehicle_me/colors.dart';
import 'package:vehicle_me/state_management/signup/profile_image_cubit.dart';
import 'package:vehicle_me/themes.dart';

class ProfilePictureUpload extends StatelessWidget {
  const ProfilePictureUpload();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 126.0,
      width: 126.0,
      child: Material(
        color: isLightTheme(context) ? kGrayLM : kLightBlueGrayDM,
        borderRadius: BorderRadius.circular(126.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(126.0),
          onTap: () async {
            await context.read<ProfileImageCubit>().getImage();
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: BlocBuilder<ProfileImageCubit, File?>(
                    builder: (context, state) {
                      return state == null
                          ? Icon(Icons.person_outline_rounded,
                              size: 126.0,
                              color: isLightTheme(context)
                                  ? kCreamLM
                                  : kDarkGrayDM)
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(126.0),
                              child: Image.file(
                                state,
                                width: 126.0,
                                height: 126.0,
                                fit: BoxFit.fill,
                              ),
                            );
                    },
                  )),
              // child:
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  Icons.add_circle_rounded,
                  color: kPurpleBlueDM,
                  size: 38,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
