part of 'home_bloc.dart';

class HomePageState extends Equatable {
  const HomePageState();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class HomeInitial extends HomePageState {
  @override
  List<Object> get props => [];
}

class HomeMyCar extends HomePageState{
  final String carID;

  HomeMyCar(this.carID);

  @override
  List<Object> get props => [carID];
}

class HomeMyCarSuccess extends HomePageState{
  final String testExpiryDate;
  final String lastTest;
  final String onRoadSince;

  HomeMyCarSuccess(this.testExpiryDate, this.lastTest, this.onRoadSince);

  @override
  List<Object?> get props => [testExpiryDate, lastTest, onRoadSince];
}


class HomeMyCarFailed extends HomePageState {

  final String error;
  HomeMyCarFailed(this.error);

  @override
  List<Object?> get props => [error];
}