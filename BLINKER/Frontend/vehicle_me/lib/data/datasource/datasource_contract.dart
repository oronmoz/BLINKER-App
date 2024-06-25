import 'package:sqflite/sqflite.dart';
import 'package:vehicle_me/domain/models/chat.dart';
import 'package:vehicle_me/domain/models/local_message.dart';

import '../../domain/models/auction.dart';
import '../../domain/models/receipt.dart';

abstract class IDataSource{
  Future<void> addChat(Chat chat);
  Future<void> addMessage(LocalMessage message);
  Future<Chat?> findChat(String chatID);
  Future<List<Chat>> findAllChats();
  Future<void> updateMessage(LocalMessage message);
  Future<List<LocalMessage>> findMessages(String chatID);
  Future<void> deleteChat(String chatID);
  Future<void> updateMessageReceipt(String messageId, ReceiptStatus status);
}