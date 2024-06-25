import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vehicle_me/domain/state_management/auth/auth_bloc.dart';
import 'package:vehicle_me/domain/models/forum.dart';

import 'forum_service_contract.dart';

class ForumService extends IForumService {

  final AuthBloc authBloc;

  final String baseURL;

  ForumService(this.authBloc, this.baseURL);
  @override
  Future<List<ForumPost>> fetchPosts() async {
    try{
      final response = await http.get(Uri.parse('$baseURL/forum/posts/'));

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        List<ForumPost> posts = jsonResponse.map((post) => ForumPost.fromJson(post)).toList();
        return posts;
      } else {
        throw Exception('Failed to load forum posts: ${response.body}');
      }
    }
    catch(e){
      final List<ForumPost> error = [];
      return (error);
    }
  }

  @override
  Future<dynamic> createPost(String title, String content, String category,
      String vehicleModel, String vehicleBrand) async {
    var token = await authBloc.getToken();
    try {
      final response = await http.post(
        Uri.parse('$baseURL/forum/create_posts/'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'content': content,
          'category': category,
          'vehicle_model': vehicleModel,
          'vehicle_brand': vehicleBrand,
        }),
      );

      if (response.statusCode == 200) {
        return ForumPost.fromJson(json.decode(response.body));
      } else {
        return ('Failed to create forum post: ${response.body}');
      }
    } catch (e) {
      return ('Failed to create forum post: $e');
    }
  }

  @override
  Future<String?> addComment(String postId, String comment) async {
    try {
      var token = await authBloc.getToken();
      final response = await http.post(
        Uri.parse('$baseURL/forum/add_comment/'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'post_id': postId,
          'content': comment,
        }),
      );

      if (response.statusCode != 200) {
        return ('Failed to add comment: ${response.body}');
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
