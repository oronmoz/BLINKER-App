import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:vehicle_me/domain/models/chat.dart';
import 'package:vehicle_me/domain/models/local_message.dart';
import 'package:vehicle_me/data/datasource/datasource_contract.dart';

abstract class BaseViewModel {
  IDataSource _datasource;

  BaseViewModel(this._datasource);

  @protected
  Future<void> addMessage(LocalMessage message) async {
    if (!await _isExistingChat(message.chat_id)) {
      final chat = Chat(message.chat_id, ChatType.individual, membersId: [
        {message.chat_id: ""}
      ]);
      await createNewChat(chat);
    }
    await _datasource.addMessage(message);
  }


  Future<bool> _isExistingChat(String chatId) async {
    return await _datasource.findChat(chatId) != null;
  }

  Future<void> createNewChat(Chat chat) async {
    await _datasource.addChat(chat);
  }
}
