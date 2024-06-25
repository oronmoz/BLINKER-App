import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vehicle_me/data/repositories/user/user_service_contract.dart';

import '../auth/auth_bloc.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  final IUserService _userService;
  final AuthBloc _authBloc;

  HomePageBloc(this._userService, this._authBloc) : super(HomeInitial()) {
    on<HomeMyCarPressed>(_onMyCarPressed);
    on<HomeExit>(_onHomeExit);
  }

  FutureOr<void> _onMyCarPressed(HomeMyCarPressed event, Emitter<HomePageState> emit) async {
    String token = await _authBloc.getToken();
    try {
      Map<String, dynamic> response = await _userService.fetchVehicleInfo(event.carID, token);
      if (response.containsKey('error')) {
        emit(HomeMyCarFailed(response['error']));
      } else {
        final String lastTestDate = response['last_test_date'];
        final String testExpirationDate = response['test_expiration_date'];
        final String onRoadDate = response['on_road_date'];
        emit(HomeMyCarSuccess(lastTestDate, testExpirationDate, onRoadDate));
      }
    } catch (e) {
      emit(HomeMyCarFailed('Error fetching vehicle info: $e'));
    }
  }

  FutureOr<void> _onHomeExit(HomeExit event, Emitter<HomePageState> emit) {
    emit(HomeInitial());
  }
}