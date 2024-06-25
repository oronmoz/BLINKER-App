part of 'onboarding_bloc.dart';
abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {}

class OnboardingLoading extends OnboardingState {}

class OnboardingVehicleInput extends OnboardingState{
  final String userInput;

  OnboardingVehicleInput(this.userInput);

  @override
  List<Object?> get props => [userInput];
}

class OnboardingVehicleSuccess extends OnboardingState{
  final String carID;

  const OnboardingVehicleSuccess(this.carID);

  @override
  List<Object?> get props => [carID];

}

class OnboardingSuccess extends OnboardingState {

  final User user;
  OnboardingSuccess(this.user);

  @override
  List<Object?> get props => [user];

}

class OnboardingError extends OnboardingState {
  final String message;

  OnboardingError(this.message);

  @override
  List<Object?> get props => [message];
}

class OnboardingRegistered extends OnboardingState{
  final User user;

  OnboardingRegistered(this.user);

  @override
  List<Object?> get props => [user];
  
}