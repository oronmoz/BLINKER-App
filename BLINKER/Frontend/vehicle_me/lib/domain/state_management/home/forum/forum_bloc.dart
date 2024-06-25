import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:vehicle_me/domain/models/forum.dart';
import 'package:vehicle_me/domain/state_management/auth/auth_bloc.dart';
import '../../../../data/repositories/forum_service/forum_service_contract.dart';
import '../../../models/user.dart';

part 'forum_event.dart';

part 'forum_state.dart';

class ForumBloc extends Bloc<ForumEvent, ForumState> {
  final IForumService _forumService;
  StreamSubscription? _subscription;

  ForumBloc(this._forumService) : super(ForumState.initial()) {
    on<ForumFetchPosts>(_onFetchPosts);
    on<FilterPosts>(_onFilterPosts);
    on<ForumAddPost>(_onAddPost);
    on<ForumAddComment>(_onAddComment);
    on<_ForumMention>(_onMention);
  }

  Future<dynamic> _onAddPost(ForumAddPost event,
      Emitter<ForumState> emit) async {
    var post = await _forumService.createPost(event.title, event.content,
        event.category, event.vehicleModel, event.vehicleBrand);
    if (post is ForumPost) {
      emit(ForumPostSuccess());
    } else {
      emit(ForumPostFailed(post as String));
    }
  }

  FutureOr<void> _onAddComment(ForumAddComment event,
      Emitter<ForumState> emit) async {
    var comment = await _forumService.addComment(event.post.id, event.comment.content);
    if (comment == null) {
      emit(const ForumPostSuccess());
    } else {
      emit(ForumPostFailed(comment));
    }
  }

  FutureOr<void> _onMention(
      _ForumMention event, Emitter<ForumState> emit) async {


  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  FutureOr<void> _onFetchPosts(
      ForumFetchPosts event, Emitter<ForumState> emit) async {
    var response = await _forumService.fetchPosts();
    if (response.isNotEmpty) {
      final List<ForumPost> posts = response.cast<ForumPost>();
      emit(ForumFetchSuccess(posts));
    } else {
      emit(ForumPostFailed('Failed to fetch posts.'));
    }
  }

  FutureOr<void> _onFilterPosts(
      FilterPosts event, Emitter<ForumState> emit) async {
    try {
      // Await the result of fetchPosts() to get the posts list
      var response = await _forumService.fetchPosts();

      if (response.isNotEmpty) {
        List<ForumPost> posts = response.cast<ForumPost>();
        posts = posts.where((post) => post.category == event.category).toList();

        // Filter posts by title if event.title is not empty
        if (event.title.isNotEmpty) {
          posts = posts
              .where((post) =>
                  post.title
                      ?.toLowerCase()
                      .contains(event.title.toLowerCase()) ??
                  false)
              .toList();
        }

        // Emit the filtered posts or update the state as required
        // Example of emitting state assuming emit is an Emitter<ForumState>
        emit(ForumFetchSuccess(posts));
      }
      // Filter posts by category
    } catch (e) {
      // Return or handle error case as needed
      // Example: emit an error state
      emit(ForumPostFailed('Error: $e'));
    }
  }
}
