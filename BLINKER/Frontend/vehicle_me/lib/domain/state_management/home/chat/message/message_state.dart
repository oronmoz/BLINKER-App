part of 'message_bloc.dart';

abstract class MessageState extends Equatable {
  const MessageState();
  factory MessageState.initial() => MessageInitial();
  factory MessageState.sent(List<Message> messages) => MessageSentSuccess(messages);
  factory MessageState.received(Message message) =>
      MessageReceivedSuccess(message);
  factory MessageState.error(String error) => MessageSendFailure(error);


  @override
  List<Object> get props => [];
}

class MessageInitial extends MessageState {}

class MessageSentSuccess extends MessageState {
  final List<Message> messages;
  const MessageSentSuccess(this.messages);

  @override
  List<Object> get props => [messages];
}

class MessageReceivedSuccess extends MessageState {
  final Message message;
  const MessageReceivedSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class MessageSendFailure extends MessageState {
  final String error;
  const MessageSendFailure(this.error);

  @override
  List<Object> get props => [error];
}