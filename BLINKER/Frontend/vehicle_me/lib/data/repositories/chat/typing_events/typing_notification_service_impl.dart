import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import '../../../../domain/models/chat.dart';
import '../../../../domain/models/typing_event.dart';
import 'typing_notification_service.dart';
import 'package:vehicle_me/domain/models/user.dart';
import 'package:vehicle_me/data/repositories/user/user_service_contract.dart';

class TypingNotification implements ITypingNotification {
  final String baseURL;
  final IUserService _userService;

  final _controller = StreamController<TypingEvent>.broadcast();
  IOWebSocketChannel? _channel;
  Timer? _reconnectionTimer;
  User? _currentUser;
  List<String?> _userIds = [];

  TypingNotification(this._userService, this.baseURL);

  @override
  Future<bool?> send({required List<TypingEvent> events}) async {
    var url = Uri.parse('$baseURL/typing_events/send_typing_event');

    try {
      print('Sending typing events: ${jsonEncode(events.map((e) => e.toJson()).toList())}');

      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(events.map((event) => event.toJson()).toList()),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to send typing events: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to send typing events: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception while sending typing events: $e');
      throw Exception('Failed to send typing events: $e');
    }
  }

  @override
  Stream<TypingEvent> subscribe(User user, List<String?> userIds) {
    _currentUser = user;
    _userIds = userIds;
    _connectWebSocket();
    return _controller.stream;
  }

  void _connectWebSocket() {
    final cleanBaseUrl = baseURL.replaceAll(RegExp(r'(http|https)://'), '');
    final wsUrl = Uri.parse('ws://$cleanBaseUrl/typing_events/ws/${_currentUser!.id}');

    print('Connecting to WebSocket: $wsUrl'); // Debugging line

    _channel = IOWebSocketChannel.connect(wsUrl);

    _channel!.stream.listen(
          (message) {
        final decodedEvent = json.decode(message);
        final typingEvent = TypingEvent.fromJson(decodedEvent);
        _controller.add(typingEvent);
        _removeDeliveredEvent(typingEvent);
      },
      onDone: _onWebSocketDone,
      onError: _onWebSocketError,
    );
  }

  void _onWebSocketDone() {
    print('WebSocket connection closed');
    _scheduleReconnection();
  }

  void _onWebSocketError(error) {
    print('WebSocket error: $error');
    _scheduleReconnection();
  }

  void _scheduleReconnection() {
    _reconnectionTimer?.cancel();
    _reconnectionTimer = Timer(Duration(seconds: 5), _connectWebSocket);
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _reconnectionTimer?.cancel();
    _controller.close();
  }

  void _removeDeliveredEvent(TypingEvent event) async {
    var url = Uri.parse('$baseURL/typing_events/${event.id}');

    try {
      var response = await http.delete(url);

      if (response.statusCode == 200) {
        print('Typing event deleted successfully');
      } else {
        print('Failed to delete typing event: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to delete typing event: $e');
    }
  }
}