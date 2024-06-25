part of 'login_cubit.dart';


abstract class LoginState extends Equatable {
  LoginState();

}

class LoginStateInitial extends LoginState {
  @override
  List<Object?> get props => [];
}

class LoginStateSubmitted extends LoginState{
  final String email;
  final String password;

  LoginStateSubmitted(this.email,this.password);
  @override
  List<Object> get props => [email,password];
}
class LoginStateLoading extends LoginState {
  @override
  List<Object?> get props => [];
}

class LoginStateError extends LoginState {
  final String errorMessage;

  LoginStateError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class LoginStateSuccess extends LoginState {
  final User? user;

  LoginStateSuccess(this.user);

  @override
  List<Object?> get props => [user];
}