import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vehicle_me/data/repositories/user/user_service.dart';
import '../../models/user.dart';
import '../auth/auth_bloc.dart';

part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final String baseURL;
  final AuthBloc authBloc;

  LoginBloc(this.baseURL, this.authBloc) : super(LoginStateInitial()) {
    on<LoginEventSubmitted>(_onSubmittedLogin);
  }

  Future<void> _onSubmittedLogin(
      LoginEventSubmitted event, Emitter<LoginState> emit) async {
    UserService userService = UserService(baseURL);

    try {
      final accessToken = await userService.login(event.email, event.password);

      if (accessToken == null) {
        emit(LoginStateError('Incorrect email or password. Failed to log in.'));
        return;
      }

      authBloc.add(AuthLoggedIn(accessToken));

      final result = await userService.fetchUserByEmail(accessToken);

      if (result.containsKey('error')) {
        final errorMessage = result['error'];
        emit(LoginStateError('Failed to fetch user details: $errorMessage'));
      } else {
        final User user = User.fromJson(result);
        emit(LoginStateSuccess(user));
      }
    } catch (e) {
      emit(LoginStateError('An error occurred: $e'));
    }
  }

}
