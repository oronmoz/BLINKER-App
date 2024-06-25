import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:vehicle_me/domain/models/user.dart';
import '../../../../models/message.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../data/repositories/chat/messages/message_service.dart';

part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final IMessageService _messageService;
  late StreamSubscription<Message> _subscription;

  MessageBloc(this._messageService) : super(MessageState.initial()) {
    on<MessageSubscribed>(_onSubscribed);
    on<_MessageReceived>(_onMessageReceived);
    on<MessageSent>(_onMessageSent);
  }

  Future<void> _onSubscribed(MessageSubscribed event, Emitter<MessageState> emit) async {
    try {
      await _messageService.connect(event.user);
      _subscription = _messageService
          .messages(activeUser: event.user)
          .listen((message) => add(_MessageReceived(message)));
    } catch (e) {
      print('Error connecting to WebSocket: $e');
      emit(MessageSendFailure('Failed to connect: $e'));
    }
  }

  void _onMessageReceived(_MessageReceived event, Emitter<MessageState> emit) {
    emit(MessageState.received(event.message));
  }

  Future<void> _onMessageSent(MessageSent event, Emitter<MessageState> emit) async {
    try {
      print("Attempting to send messages: ${event.messages}");
      final messages = await _messageService.send(event.messages);
      print("Messages sent successfully: $messages");
      emit(MessageSentSuccess(messages));
    } catch (e) {
      print("Error in _onMessageSent: $e");
      emit(MessageSendFailure('Failed to send message: $e'));
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    _messageService.dispose();
    return super.close();
  }
}