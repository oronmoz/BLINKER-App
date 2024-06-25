import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:vehicle_me/domain/models/user.dart';
import 'local_message.dart';
import 'message.dart';
import 'dart:convert';



enum ChatType { individual, group }

extension EnumParsing on ChatType {
  String value() {
    return this.toString().split('.').last;
  }

  static ChatType fromString(String status) {
    return ChatType.values.firstWhere((element) => element.value() == status);
  }
}

class Chat {
  String id;
  String? name;
  ChatType type;
  List<User> members;
  List<Map<String, dynamic>> membersId;
  LocalMessage? mostRecent;
  int unread;

  Chat(
      this.id,
      this.type, {
        this.name,
        this.members = const [],
        required this.membersId,
        this.mostRecent,
        this.unread = 0,
      });

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      map['id'],
      ChatType.values.firstWhere((e) => e.toString() == 'ChatType.${map['type']}'),
      name: map['name'],
      membersId: (jsonDecode(map['members']) as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      mostRecent: map['mostRecent'] != null
          ? LocalMessage.fromMap(jsonDecode(map['mostRecent']))
          : null,
      unread: map['unread'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'members': jsonEncode(membersId),
      'mostRecent': mostRecent != null ? jsonEncode(mostRecent!.toMap()) : null,
      'unread': unread,
    };
  }
}