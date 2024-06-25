import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vehicle_me/data/repositories/chat/group_service/groups_service_contract.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../../domain/models/group_chat.dart';

class GroupService extends IGroupService {
  final String baseUrl;
  WebSocketChannel? _channel;

  GroupService({required this.baseUrl});

  Future<GroupChat> create(GroupChat group) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create_group'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(group.toJson()),
    );

    if (response.statusCode == 200) {
      return GroupChat.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create group');
    }
  }

  Stream<GroupChat> groups(String userEmail) {
    _channel = WebSocketChannel.connect(
      Uri.parse('$baseUrl/ws/groups/${Uri.encodeComponent(userEmail)}'),
    );

    return _channel!.stream.map((data) {
      final jsonData = jsonDecode(data);
      return GroupChat.fromJson(jsonData);
    });
  }

  void dispose() {
    _channel?.sink.close();
  }
}
