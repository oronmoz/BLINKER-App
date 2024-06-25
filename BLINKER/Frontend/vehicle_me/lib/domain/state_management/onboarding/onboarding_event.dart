part of 'onboarding_bloc.dart';
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class SkipToLoginEvent extends OnboardingEvent {}

class UserInputEvent extends OnboardingEvent {
  final String userInput;

  const UserInputEvent(this.userInput);

  @override
  List<Object> get props => [userInput];

}

class RegisterEvent extends OnboardingEvent {
  final Map<String, dynamic> userData;

  RegisterEvent(this.userData);

  @override
  List<Object?> get props => [userData];
}