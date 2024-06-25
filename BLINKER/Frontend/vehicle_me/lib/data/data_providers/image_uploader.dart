import 'dart:io';
import 'package:http/http.dart';

/// Responsible for uploading images to a server.
class ImageUploader {
  final _url;

  /// Constructs a new [ImageUploader] instance.
  ///
  /// [_url] - The base URL of the server where the images will be uploaded.
  ImageUploader(this._url);

  /// Uploads an image to the server.
  ///
  /// [image] - The [File] object representing the image to be uploaded.
  ///
  /// Returns the full URL of the uploaded image if the upload is successful, otherwise `null`.
  Future<String?> uploadImage(File image) async {
    final request = MultipartRequest('POST', Uri.parse(_url));
    request.files.add(await MultipartFile.fromPath('picture', image.path));
    final result = await request.send();
    // Return null for an unsuccessful status
    if (result.statusCode != 200){
      return null;
    }
    final response = await Response.fromStream(result);
    return Uri.parse(_url).origin + response.body;

  }

}