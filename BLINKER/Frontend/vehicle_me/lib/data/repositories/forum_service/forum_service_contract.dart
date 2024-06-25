import 'package:vehicle_me/domain/models/forum.dart';

abstract class IForumService {

  Future<List<ForumPost>> fetchPosts();

  Future<dynamic> createPost(String title, String content, String category, String vehicleModel, String vehicleBrand);

  Future<String?> addComment(String postId, String comment);
}