import 'dart:async';
import 'dart:convert';
import 'package:vehicle_me/domain/models/vehicle.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vehicle_me/data/repositories/user/user_service_contract.dart';

import '../../models/user.dart';

part 'onboarding_event.dart';

part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final IUserService _userService;
  int currentSlideIndex = 0; // Initialize with the first slide index
  late String userInput;

  OnboardingBloc(this._userService) : super(OnboardingLoading()) {
    on<UserInputEvent>(_onUserInput);
    on<RegisterEvent>(_onRegistration);
    on<SkipToLoginEvent>(_onSkipToLogin);
  }

  void _onUserInput(
      OnboardingEvent event, Emitter<OnboardingState> emitter) async {
    emitter(OnboardingVehicleSuccess((event as UserInputEvent).userInput));
  }

  void _onSkipToLogin(OnboardingEvent event, Emitter<OnboardingState> emitter) {
    emitter(OnboardingLoading());
  }

  Future<void> _onRegistration(
      OnboardingEvent event, Emitter<OnboardingState> emit) async {
    Map<String, dynamic> userData = (event as RegisterEvent).userData;
    try {
      var result = await _userService.registerUser(userData);
      // An error message returned
      if (result.containsKey('data')) {
        final user = result['data'];
        emit(OnboardingRegistered(user));
      } else {
        final errorMessage = result['error'];
        emit(OnboardingError('Failed to fetch user details: $errorMessage'));
      }
    } catch (e) {
      emit(OnboardingError('An error occurred: $e'));
    }
  }
}
