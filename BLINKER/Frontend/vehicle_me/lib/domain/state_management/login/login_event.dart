part of 'login_cubit.dart';

abstract class LoginEvent {}

class LoginEventInitial extends LoginEvent {

  List<Object> get props => [];
}

class LoginEventSubmitted extends LoginEvent {
  final String email;
  final String password;

  LoginEventSubmitted(this.email, this.password);

  @override
  List<Object> get props => [email,password];

}
