part of 'forum_bloc.dart';

abstract class ForumEvent extends Equatable {
  const ForumEvent();
  @override
  List<Object?> get props => [];
}

class ForumAddPost extends ForumEvent {

  final String title;
  final String content;
  final String category;
  final String vehicleModel;
  final String vehicleBrand;

  ForumAddPost (this.content, this.category, this.vehicleModel, this.vehicleBrand, this.title);

  @override
  List<Object?> get props => [title, content, category, vehicleModel, vehicleBrand];

}

class ForumFetchPosts extends ForumEvent {
  @override
  List<Object> get props => [];
}

class ForumAddComment extends ForumEvent {
  final Comment comment;
  final ForumPost post;
  ForumAddComment (this.comment, this.post);

  @override
  List<Object?> get props => [comment, post];
}

class _ForumMention extends ForumEvent {
  final  User user;
  _ForumMention(this.user);

  @override
  List<Object?> get props => [user];
}

class FilterPosts extends ForumEvent {
  final String category;
  final String title;

  FilterPosts(this.category, this.title);

  @override
  List<Object?> get props => [category, title];
}

class ClearFilters extends ForumEvent {}