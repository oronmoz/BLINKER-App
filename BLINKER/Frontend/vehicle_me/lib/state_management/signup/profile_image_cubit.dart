import 'dart:io';
import 'package:vehicle_me/data/data_providers/image_uploader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';


class ProfileImageCubit extends Cubit<File?> {
  final _picker = ImagePicker();

  ProfileImageCubit() : super(null); // Set initial state to null

  // Let user pick an image from Gallery, and return the image path
  Future<void> getImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      if (image != null) {
        emit(File(image.path));
      }
    } catch (e) {
      // Handle error accordingly, for example, emit a state with an error message or log the error
      return;
    }
  }
}