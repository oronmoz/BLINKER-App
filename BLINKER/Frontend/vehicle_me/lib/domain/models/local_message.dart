import 'dart:convert';

import 'package:vehicle_me/domain/models/receipt.dart';
import 'message.dart';

class LocalMessage {
  String get id => _id;
  String chat_id;
  Message message;
  ReceiptStatus receiptStatus;
  late String _id;

  LocalMessage(this.chat_id, this.message, this.receiptStatus);

  Map<String, dynamic> toMap() => {
        'chat_id': chat_id,
        'id': message.id,
        'sender': message.sender,
        'receiver': message.recipient,
        'contents': message.contents,
        'received_at': message.time_stamp,
        'receipt': receiptStatus.value(),
      };

  factory LocalMessage.fromMap(Map<String, dynamic> json) {
    final message = Message(
      recipient: json['receiver'],
      sender: json['sender'],
      contents: json['contents'],
      time_stamp: json['received_at'] as String? ?? DateTime.now().toIso8601String(),
    );
    final localMessage = LocalMessage(
      json['chat_id'] as String? ?? '',
      message,
      ReceiptParsing.fromString(json['receipt']),
    );
    localMessage._id = json['id'] as String? ?? '';
    return localMessage;
  }
}
