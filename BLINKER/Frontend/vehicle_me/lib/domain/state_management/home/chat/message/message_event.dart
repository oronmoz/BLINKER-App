part of 'message_bloc.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object> get props => [];
}

class MessageSubscribed extends MessageEvent {
  final User user;

  const MessageSubscribed(this.user);

  @override
  List<Object> get props => [user];
}

class MessageSent extends MessageEvent {
  final List<Message> messages;

  const MessageSent(this.messages);

  @override
  List<Object> get props => [messages];
}

class _MessageReceived extends MessageEvent {
  final Message message;

  const _MessageReceived(this.message);

  @override
  List<Object> get props => [message];
}