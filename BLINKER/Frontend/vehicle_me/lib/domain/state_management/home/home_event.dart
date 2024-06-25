part of 'home_bloc.dart';

class HomePageEvent extends Equatable {
  HomePageEvent();

  @override
  List<Object?> get props => [];
}

class HomeExit extends HomePageEvent{}

class HomeMyCarPressed extends HomePageEvent {
  final String carID;

  HomeMyCarPressed(this.carID);

  @override
  List<Object?> get props => [carID];
}

