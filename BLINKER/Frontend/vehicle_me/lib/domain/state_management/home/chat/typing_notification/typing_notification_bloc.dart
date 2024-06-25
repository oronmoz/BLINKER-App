import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:vehicle_me/domain/models/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../data/repositories/chat/typing_events/typing_notification_service.dart';
import 'package:vehicle_me/domain/models/typing_event.dart';

part 'typing_notification_event.dart';

part 'typing_notification_state.dart';

class TypingNotificationBloc
    extends Bloc<TypingNotificationEvent, TypingNotificationState> {
  final ITypingNotification _typingNotification;
  StreamSubscription? _subscription;

  TypingNotificationBloc(this._typingNotification)
      : super(TypingNotificationState.initial()) {
    on<Subscribed>(_onSubscribed);
    on<TypingNotificationReceived>(_onTypingNotificationReceived);
    on<TypingNotificationSent>(_onTypingNotificationSent);
    on<NotSubscribed>(_onNotSubscribed);
  }

  void _onSubscribed(
      Subscribed event, Emitter<TypingNotificationState> emit) async {
    if (event.usersWithChat == null) {
      add(NotSubscribed());
      return;
    }
    await _subscription?.cancel();
    _subscription = _typingNotification
        .subscribe(event.user, event.usersWithChat!)
        .listen((typingEvent) => add(TypingNotificationReceived(typingEvent)));
  }

  void _onTypingNotificationReceived(TypingNotificationReceived event,
      Emitter<TypingNotificationState> emit) {
    emit(TypingNotificationState.received(event.event));
  }

  void _onTypingNotificationSent(TypingNotificationSent event,
      Emitter<TypingNotificationState> emit) async {
    try {
      await _typingNotification.send(events: event.events);
      emit(TypingNotificationState.sent());
    } catch (e) {
      emit(TypingNotificationSentFailure(e.toString()));
    }
  }

  void _onNotSubscribed(
      NotSubscribed event, Emitter<TypingNotificationState> emit) {
    emit(TypingNotificationState.initial());
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _typingNotification.dispose();
    return super.close();
  }
}
