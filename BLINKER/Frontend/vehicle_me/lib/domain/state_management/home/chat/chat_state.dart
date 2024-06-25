import 'package:equatable/equatable.dart';

import '../../../models/chat.dart';
import '../../../models/user.dart';

abstract class ChatState extends Equatable{}

class ChatStateInitial extends ChatState{
  @override
  List<Object?> get props => [];
}

class ChatLoading extends ChatState{
  @override
  List<Object?> get props => [];
}

class ChatSuccess extends ChatState{
  final List<User> onlineUsers;
  ChatSuccess(this.onlineUsers);
  @override
  List<Object?> get props => [onlineUsers];
}

class ChatFetchSuccess extends ChatState{
  final Chat chat;
  ChatFetchSuccess(this.chat);
  @override
  List<Object?> get props => [chat];
}

class ChatError extends ChatState{
  final String error;

  ChatError(this.error);

  @override
  List<Object?> get props => [error];
}