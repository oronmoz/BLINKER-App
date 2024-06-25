import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/user.dart';
import '../../models/vehicle.dart';

part 'my_profile_state.dart';

class MyProfileCubit extends Cubit<int> {

  MyProfileCubit(int changeState) : super(0);

  void showProfile() => emit(state+1);

  void hideProfile() => emit(state-1);
}

