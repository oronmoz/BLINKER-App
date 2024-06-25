import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vehicle_me/data/repositories/user/user_service_contract.dart';
import 'package:vehicle_me/domain/models/chat.dart';
import 'package:vehicle_me/domain/state_management/home/chat/chat_state.dart';

import '../../../models/user.dart';
import 'chat_event.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final IUserService _userService;

  final String token;

  ChatBloc(this._userService, this.token) : super(ChatLoading()) {
    on<ChatCreate>(_onChatCreate);
    on<ChatEventInitial>(_onChatInit);


    @override
    void emit(ChatState state) async {
      emit(ChatLoading());
      print(token);
      final users = await _userService.online(token);
      super.emit(ChatSuccess(users));
    }
  }


  FutureOr<void> _onChatInit(ChatEventInitial event, Emitter<ChatState> emit) async {
    emit(ChatStateInitial());
  }


  FutureOr<void> _onChatCreate(ChatCreate event, Emitter<ChatState> emit) async {
    try {
      emit(ChatLoading());
      List<User> users = await _userService.fetchUsersByCarIds(event.carIds, token);
      if (users.isNotEmpty) {
        if (users.length == 1) {
          Chat newChat = Chat(
            users[0].email,
            ChatType.individual,
            members: users,
            membersId: users.map((user) => {
              'email': user.email,
              'carId': user.vehicle.carId,
              'first_name': user.first_name,
              'last_name': user.last_name,
            }).toList(),
          );
          emit(ChatFetchSuccess(newChat));
        } else {
          // TODO: Handle group chat creation
          emit(ChatError('Group chat creation not implemented yet'));
        }
      } else {
        emit(ChatError('No users found for the given vehicle number'));
      }
    } catch (e) {
      emit(ChatError('$e'));
    }
  }

}
