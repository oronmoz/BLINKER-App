import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vehicle_me/ui/widgets/shared/custom_text_field.dart';
import '../../../domain/models/forum.dart';
import '../../../domain/models/user.dart';
import '../../../domain/state_management/home/forum/forum_bloc.dart';
import '../../widgets/shared/custom_text_field.dart';

class PostDetailPage extends StatefulWidget {
  final ForumPost post;
  final User user;

  PostDetailPage({required this.post, required this.user});

  @override
  _PostDetailPageContentState createState() => _PostDetailPageContentState();
}

class _PostDetailPageContentState extends State<PostDetailPage> {
  late TextEditingController _commentController;
  late final ForumPost post;
  late final User user;
  late List<Comment> comments = [];

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    var _forumBloc = BlocProvider.of<ForumBloc>(context);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Detail'),
      ),
      body: Center(
        child: BlocListener<ForumBloc, ForumState>(
          listener: (context, state) {
            var _forumBloc = context.read<ForumBloc>();
            if (state is ForumPostFailed) {
              _forumBloc.add(ForumFetchPosts());
              Navigator.pop(context);
            }

            if (state is ForumPostSuccess) {
              User user = widget.user;
              ForumPost post = widget.post;
              _forumBloc.add(ForumFetchPosts());
            }
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.post.title ?? 'No content'),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(widget.post.category ?? 'No content'),
                      Text(widget.post.vehicleBrand ?? 'No content'),
                      Text(widget.post.vehicleModel ?? 'No content'),
                      Text(widget.post.createdAt ?? 'No content'),
                    ],
                  ),
                  SizedBox(height: 30),

                  Text(widget.post.content ?? 'No content'),

                  // Display list of comments
                  SizedBox(height: 90),
                  if (widget.post.comments.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.post.comments.map((comment) {
                        return Column(
                          children: [
                            ListTile(
                              subtitle: Text(comment.userEmail),
                              title: Text(comment.content),
                              trailing: Text(comment.createdAt),
                            ),
                            SizedBox(height: 10),
                          ],
                        );
                      }).toList(),
                    ),

                  SizedBox(height: 60),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 75,
                        width: 200,
                        child: CustomTextField(
                          hint: "Comment...",
                          height: 54.0,
                          onChanged: (val) {},
                          inputAction: TextInputAction.done,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 50),
                        child: Container(
                          width: 90,
                          height: 70,
                          child: ElevatedButton(
                            onPressed: () {
                              User user = widget.user;
                              ForumPost post = widget.post;
                              var _forumBloc = context.read<ForumBloc>();
                              _onAddCommentPressed(user, _forumBloc, post);
                            },
                            child: Text('Comment'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onAddCommentPressed(User user, ForumBloc _forumBloc, ForumPost post) {
    String commentText = _commentController.text;
    _commentController.clear();
    Comment comment = Comment(
        userEmail: user.email,
        content: commentText,
        createdAt: DateTime.now().toIso8601String());
    _forumBloc.add(ForumAddComment(comment, post));
  }
}
