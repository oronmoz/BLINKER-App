import 'package:vehicle_me/colors.dart';

import '../../../domain/models/forum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/models/user.dart';
import '../../../domain/state_management/home/forum/forum_bloc.dart';

class ForumScreen extends StatelessWidget {
  final User user;

  ForumScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    final ForumBloc _forumBloc = context.read<ForumBloc>();
    _forumBloc.add(ForumFetchPosts());
    return Scaffold(
      appBar: AppBar(
        title: Text('Forum'),
      ),
      body: BlocListener<ForumBloc, ForumState>(
        listener: (context, state) {
          if (state is ForumPostFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to create post: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
            _forumBloc.add(ForumFetchPosts());
            Navigator.of(context).pop();
          } else if (state is ForumPostSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Post fetched successfully'),
                backgroundColor: Colors.green,
              ),
            );
            _forumBloc.add(ForumFetchPosts());
            Navigator.of(context).pop();
          }
        },
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      _showCreatePostDialog(context, _forumBloc);
                    },
                    child: Text('Create Post', style: TextStyle(
                      color: kDarkGray
                    ),),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _showFilterPostsDialog(context, _forumBloc);
                    },
                    child: Text('Filter Posts', style: TextStyle(
                        color: kDarkGray
                    ),),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<ForumBloc, ForumState>(
                builder: (context, state) {
                  if (state is ForumFetchSuccess) {
                    return _buildForumList(state.posts);
                  } else if (state is ForumPostFailed) {
                    return Center(
                        child: Text('Failed to fetch posts: ${state.error}'));
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForumList(List<ForumPost> posts) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        ForumPost post = posts[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: ListTile(
            tileColor: kBackground.withOpacity(0.85),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            title: Text(post.title ?? 'No title'),
            subtitle: Text(
                '${post.vehicleModel ?? 'No model'} - ${post.vehicleBrand ?? 'No brand'}'),
            trailing: Text(post.category ?? 'No category'),
            onTap: () {
              Navigator.pushNamed(
                context,
                'post_detail_page',
                arguments: {
                  'user': user,
                  'post': post,
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showCreatePostDialog(BuildContext context, ForumBloc forumBloc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String title = '';
        String content = '';
        String category = 'General';
        String vehicleModel = '';
        String vehicleBrand = '';

        return AlertDialog(
          title: Text('Create Post'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  onChanged: (value) => title = value,
                  decoration: InputDecoration(hintText: 'Title'),
                ),
                TextField(
                  onChanged: (value) => content = value,
                  decoration: InputDecoration(hintText: 'Content'),
                ),
                DropdownButtonFormField<String>(
                  value: category,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      category = newValue;
                    }
                  },
                  items: <String>[
                    'General',
                    'Help',
                    'Urgent',
                    'Vehicle Support',
                    'Other'
                  ]
                      .map<DropdownMenuItem<String>>(
                        (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                  decoration: InputDecoration(hintText: 'Category'),
                ),
                TextField(
                  onChanged: (value) => vehicleModel = value,
                  decoration: InputDecoration(hintText: 'Vehicle Model'),
                ),
                TextField(
                  onChanged: (value) => vehicleBrand = value,
                  decoration: InputDecoration(hintText: 'Vehicle Brand'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                forumBloc.add(ForumFetchPosts());
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Post'),
              onPressed: () {
                forumBloc.add(ForumAddPost(
                  title,
                  content,
                  category,
                  vehicleModel,
                  vehicleBrand,
                ));

                //);
                //Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showFilterPostsDialog(BuildContext context, ForumBloc forumBloc) {
    String filterCategory = 'All';
    String filterTitle = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter Posts'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DropdownButtonFormField<String>(
                  value: filterCategory,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      filterCategory = newValue;
                    }
                  },
                  items: <String>[
                    'All',
                    'General',
                    'Help',
                    'Urgent',
                    'Vehicle Support',
                    'Other'
                  ]
                      .map<DropdownMenuItem<String>>(
                        (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                  decoration: InputDecoration(hintText: 'Category'),
                ),
                TextField(
                  onChanged: (value) {
                    filterTitle = value;
                  },
                  decoration: InputDecoration(hintText: 'Title Keywords'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                forumBloc.add(ForumFetchPosts());
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Filter'),
              onPressed: () {
                Navigator.of(context).pop();
                forumBloc.add(FilterPosts(filterCategory, filterTitle));
              },
            ),
            ElevatedButton(
              child: Text('Clear Filters'),
              onPressed: () {
                forumBloc.add(ForumFetchPosts());
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
