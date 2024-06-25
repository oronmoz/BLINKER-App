part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable{




}

class AuthLoggedIn extends AuthEvent {

  final String token;
  AuthLoggedIn(this.token);

  @override
  List<Object> get props => [token];
}


class AuthLoggedOut extends AuthEvent {

  @override
  List<Object> get props => [];
}

