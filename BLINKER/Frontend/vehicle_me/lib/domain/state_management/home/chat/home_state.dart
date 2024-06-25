part of 'home_cubit.dart';

abstract class HomeState extends Equatable {}

class HomeInitial extends HomeState {
  @override
  List<Object> get props => [];
}

class HomeLoading extends HomeState {
  @override
  List<Object> get props => [];
}

class HomeSuccess extends HomeState {
  final List<User> onlineUsers;
  HomeSuccess(this.onlineUsers);

  @override
  List<Object> get props => [onlineUsers];
}

class HomeError extends HomeState {
  final String error;
  HomeError(this.error);

  @override
  List<Object> get props => [error];
}