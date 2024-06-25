part of 'group_chat_bloc.dart';

// Events
abstract class GroupChatEvent extends Equatable {
  const GroupChatEvent();

  @override
  List<Object?> get props => [];
}

class Subscribed extends GroupChatEvent {
  final String userEmail;
  const Subscribed(this.userEmail);

  @override
  List<Object?> get props => [userEmail];
}

class GroupChatCreated extends GroupChatEvent {
  final GroupChat group;
  const GroupChatCreated(this.group);

  @override
  List<Object?> get props => [group];
}

class _GroupChatReceived extends GroupChatEvent {
  final GroupChat group;
  const _GroupChatReceived(this.group);

  @override
  List<Object?> get props => [group];
}