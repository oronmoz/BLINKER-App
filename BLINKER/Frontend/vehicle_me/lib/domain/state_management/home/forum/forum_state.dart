part of 'forum_bloc.dart';

abstract class ForumState extends Equatable {
  const ForumState();

  factory ForumState.initial() => ForumInitial();

  @override
  List<Object> get props => [];
}

class ForumInitial extends ForumState {
  @override
  List<Object> get props => [];
}

class ForumFetchSuccess extends ForumState {
  final List<ForumPost> posts;

  const ForumFetchSuccess(this.posts);
  @override
  List<Object> get props => [posts];
}


class ForumPostSuccess extends ForumState {

  const ForumPostSuccess();
  @override
  List<Object> get props => [];
}

class MentionSuccess extends ForumState {

  final String mentions;

  const MentionSuccess(this.mentions);

  @override
  List<Object> get props => [mentions];
}

class ForumPostFailed extends ForumState  {

final String error;

const ForumPostFailed(this.error);

@override
List<Object> get props => [error];
}
