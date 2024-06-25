part of 'typing_notification_bloc.dart';

abstract class TypingNotificationEvent extends Equatable {
  const TypingNotificationEvent();

  factory TypingNotificationEvent.onSubscribed(User user,
      {required List<String> usersWithChat}) =>
      Subscribed(user, usersWithChat: usersWithChat);

  factory TypingNotificationEvent.onTypingEventSent(List<TypingEvent> events) =>
      TypingNotificationSent(events);

  @override
  List<Object?> get props => [];
}

class Subscribed extends TypingNotificationEvent {
  final User user;
  final List<String> usersWithChat;
  const Subscribed(this.user, {required this.usersWithChat});

  @override
  List<Object?> get props => [user, usersWithChat];
}

class NotSubscribed extends TypingNotificationEvent {}

class TypingNotificationSent extends TypingNotificationEvent {
  final List<TypingEvent> events;
  const TypingNotificationSent(this.events);

  @override
  List<Object?> get props => [events];
}

class TypingNotificationReceived extends TypingNotificationEvent {
  const TypingNotificationReceived(this.event);
  final TypingEvent event;

  @override
  List<Object?> get props => [event];
}

class TypingNotificationSentFailure extends TypingNotificationState {
  final String error;

  const TypingNotificationSentFailure(this.error);

  @override
  List<Object> get props => [error];
}