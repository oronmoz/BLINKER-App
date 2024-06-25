import 'dart:convert';

import 'package:flutter/material.dart';
import '../../domain/models/auction.dart';
import '../../domain/models/chat.dart';
import '../../domain/models/local_message.dart';
import '../../domain/models/message.dart';
import '../../domain/models/receipt.dart';
import 'datasource_contract.dart';
import 'package:sqflite/sqflite.dart';
import 'package:collection/collection.dart';

/// Constructs a [Datasource] with the provided [Database].
class Datasource implements IDataSource {
  final Database _db;

  /// Constructs a Datasource with the provided Database.
  const Datasource(this._db);


  /// Adds a new [Chat] to the database.
  ///
  /// If a chat with the same ID already exists, it will be replaced.
  ///
  /// [chat] - The [Chat] object to be added.
  @override
  Future<void> addChat(Chat chat) async {
    await _db.transaction((txn) async {
      await txn.insert(
        'chats',
        {
          'id': chat.id,
          'name': chat.name,
          'type': chat.type.toString(),
          'members': jsonEncode(chat.membersId),
          'mostRecent': chat.mostRecent?.receiptStatus.value(),
          'unread': chat.unread.toString(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  /// Adds a new [LocalMessage] to the database.
  ///
  /// If a message with the same ID already exists, it will be replaced.
  ///
  /// [message] - The [LocalMessage] object to be added.
  @override
  Future<void> addMessage(LocalMessage message) async {
    await _db.transaction((txn) async {
      await txn.insert('messages', message.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      await txn.update(
          'chats', {'updated_at': message.message.time_stamp},
          where: 'id = ?', whereArgs: [message.chat_id]);
    });
  }


  /// Deletes a [Chat] and its associated messages from the database.
  ///
  /// [chat_id] - The ID of the chat to be deleted.
  @override
  Future<void> deleteChat(String chatId) async {
    final batch = _db.batch();
    batch.delete('messages', where: 'chat_id = ?', whereArgs: [chatId]);
    batch.delete('chats', where: 'id = ?', whereArgs: [chatId]);
    await batch.commit(noResult: true);
  }

  /// Retrieves all chats from the database along with their most recent message and unread message count.
  ///
  /// Returns a list of [Chat] objects.
  @override
  Future<List<Chat>> findAllChats() {
    return _db.transaction((txn) async {
      final listOfChatMaps =
      await txn.query('chats', orderBy: 'updated_at DESC');

      if (listOfChatMaps.isEmpty) return [];

      return await Future.wait(listOfChatMaps.map<Future<Chat>>((row) async {
        final unread = Sqflite.firstIntValue(await txn.rawQuery(
            'SELECT COUNT(*) FROM MESSAGES WHERE chat_id = ? AND receipt = ?',
            [row['id'], 'delivered']));

        final mostRecentMessage = await txn.query('messages',
            where: 'chat_id = ?',
            whereArgs: [row['id']],
            orderBy: 'created_at DESC',
            limit: 1);
        final chat = Chat.fromMap(row);
        chat.unread = unread ?? 0;
        if (mostRecentMessage.isNotEmpty) {
          chat.mostRecent = LocalMessage.fromMap(mostRecentMessage.first);
        }
        return chat;
      }));
    });
  }

  /// Retrieves a specific [Chat] by its ID.
  ///
  /// [chat_id] - The ID of the chat to be retrieved.
  ///
  /// Returns a [Chat] object if found, otherwise returns null.
  @override
  Future<Chat?> findChat(String chatId) async {
    return await _db.transaction((txn) async {
      final listOfChatMaps = await txn.query(
        'chats',
        where: 'id = ?',
        whereArgs: [chatId],
      );

      if (listOfChatMaps.isEmpty) return null;

      final unread = Sqflite.firstIntValue(await txn.rawQuery(
          'SELECT COUNT(*) FROM MESSAGES WHERE chat_id = ? AND receipt = ?',
          [chatId, 'delivered']));

      final mostRecentMessage = await txn.query('messages',
          where: 'chat_id = ?',
          whereArgs: [chatId],
          orderBy: 'created_at DESC',
          limit: 1);
      final chat = Chat.fromMap(listOfChatMaps.first);
      chat.unread = unread ?? 0;
      if (mostRecentMessage.isNotEmpty) {
        chat.mostRecent = LocalMessage.fromMap(mostRecentMessage.first);
      }
      return chat;
    });
  }

  /// Retrieves all messages associated with a specific chat.
  ///
  /// [chat_id] - The ID of the chat whose messages are to be retrieved.
  ///
  /// Returns a list of [LocalMessage] objects.
  @override
  Future<List<LocalMessage>> findMessages(String chatId) async {
    try {
      final listOfMaps = await _db.query(
        'messages',
        where: 'chat_id = ?',
        whereArgs: [chatId],
      );

      return listOfMaps.map<LocalMessage>((map) {
        try {
          return LocalMessage.fromMap(map);
        } catch (e) {
          print('Error parsing message: $e');
          print('Problematic data: $map');
          // Return a default message or skip this message
          return LocalMessage(
            chatId,
            Message(
              recipient: '',
              sender: '',
              contents: 'Error: Could not load message',
              time_stamp: DateTime.now().toIso8601String(),
            ),
            ReceiptStatus.sent,
          );
        }
      }).toList();
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }

  /// Updates an existing [LocalMessage] in the database.
  ///
  /// [message] - The [LocalMessage] object to be updated.
  @override
  Future<void> updateMessage(LocalMessage message) async {
    await _db.update('messages', message.toMap(),
        where: 'id = ?',
        whereArgs: [message.message.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> updateMessageReceipt(String messageId, ReceiptStatus status) {
    return _db.transaction((txn) async {
      await txn.update('messages', {'receipt': status.value()},
          where: 'id = ?',
          whereArgs: [messageId],
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }
}

