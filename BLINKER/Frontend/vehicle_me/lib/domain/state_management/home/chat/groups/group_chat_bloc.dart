import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../data/repositories/chat/group_service/groups_service_contract.dart';
import '../../../../models/group_chat.dart';
import '../../../../models/user.dart';


part 'group_chat_event.dart';
part 'group_chat_state.dart';

class GroupChatBloc extends Bloc<GroupChatEvent, GroupChatState> {
  GroupChatBloc(this._groupService) : super(GroupChatInitial()) {
    on<Subscribed>(_onSubscribed);
    on<GroupChatCreated>(_onGroupChatCreated);
    on<_GroupChatReceived>(_onGroupChatReceived);
  }

  final IGroupService _groupService;
  StreamSubscription? _subscription;

  Future<void> _onSubscribed(Subscribed event, Emitter<GroupChatState> emit) async {
    await _subscription?.cancel();
    _subscription = _groupService
        .groups(event.userEmail)
        .listen((group) => add(_GroupChatReceived(group)));
  }

  Future<void> _onGroupChatCreated(GroupChatCreated event, Emitter<GroupChatState> emit) async {
    try {
      final group = await _groupService.create(event.group);
      emit(GroupChatCreatedSuccess(group));
    } catch (e) {
      emit(GroupChatError('Failed to create group: $e'));
    }
  }

  void _onGroupChatReceived(_GroupChatReceived event, Emitter<GroupChatState> emit) {
    emit(GroupChatReceived(event.group));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _groupService.dispose();
    return super.close();
  }
}