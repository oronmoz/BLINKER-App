import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/user/user_service_contract.dart';
import '../../../models/user.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  IUserService _userService;

  //ILocalCache _localCache;

  HomeCubit(
    this._userService,
    /*this._localCache*/
  ) : super(HomeInitial());

  // Future<User> connect() async {
  //   final userJson = _localCache.fetch('USER');
  //   userJson['last_seen'] = DateTime.now();
  //   userJson['active'] = true;
  //
  //   final user = User.fromJson(userJson);
  //   await _userService.connect(user);
  //   return user;
  // }

  Future<void> activeUsers(User user, String token) async {
    emit(HomeLoading()); // 1. Emitting a loading state

    try {
      // Fetch the list of online users
      final users = await _userService.online(token);

      // Remove the user from the list
      users.removeWhere((element) => element.id == user.id);

      // Emit the success state with the updated user list
      emit(HomeSuccess(users));
    } catch (e) {
      emit(HomeError('$e'));
    }
  }

  // Future<void> activeUsers(User user, Future<String?> tokenFuture) async {
  //   emit(HomeLoading());
  //   try {
  //     // Fetch the list of online users using the token
  //     final users = await _userService.online(token);
  //
  //     // Remove the user from the list if present
  //     users.removeWhere((element) => element.id == user.id);
  //
  //     // Emit success with the updated user list
  //     emit(HomeSuccess(users));
  //   } catch (e) {
  //     emit(HomeError(e.toString()));
  //     throw Exception(e);
  //   }
  // }
}
