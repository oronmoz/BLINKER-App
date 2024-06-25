part of 'group_chat_bloc.dart';

// States
abstract class GroupChatState extends Equatable {
  const GroupChatState();

  @override
  List<Object?> get props => [];
}

class GroupChatInitial extends GroupChatState {}

class GroupChatCreatedSuccess extends GroupChatState {
  final GroupChat group;
  const GroupChatCreatedSuccess(this.group);

  @override
  List<Object?> get props => [group];
}

class GroupChatReceived extends GroupChatState {
  final GroupChat group;
  const GroupChatReceived(this.group);

  @override
  List<Object?> get props => [group];
}

class GroupChatError extends GroupChatState {
  final String message;
  const GroupChatError(this.message);

  @override
  List<Object?> get props => [message];
}