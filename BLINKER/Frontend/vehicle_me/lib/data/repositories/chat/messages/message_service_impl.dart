import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:vehicle_me/domain/models/user.dart';
import 'package:vehicle_me/domain/models/message.dart';
import '../../../../config.dart';
import 'encryption_service.dart';
import 'message_service.dart';
import 'package:http/http.dart' as http;


class MessageService implements IMessageService {
  final String token;
  final IEncryption? _encryption;
  final StreamController<Message> _messageController = StreamController<Message>.broadcast();
  IOWebSocketChannel? _channel;
  User? _currentUser;
  Timer? _reconnectionTimer;

  MessageService(this.token, {IEncryption? encryption}) : _encryption = encryption;

  @override
  Future<void> connect(User user) async {
    _currentUser = user;
    _connectWebSocket();
  }

  void _connectWebSocket() {
    final cleanBaseUrl = baseURL.replaceAll(RegExp(r'(http|https)://'), '');
    final wsUrl = Uri.parse('ws://$cleanBaseUrl/messages/ws/${_currentUser!.id}');

    print('Connecting to WebSocket: $wsUrl');

    _channel = IOWebSocketChannel.connect(wsUrl);

    _channel!.stream.listen(
          (message) {
        final decodedMessage = json.decode(message);
        final chatMessage = Message.fromJson(decodedMessage);
        if (_encryption != null) {
          chatMessage.contents = _encryption.decrypt(chatMessage.contents);
        }
        _messageController.add(chatMessage);
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
    _messageController.close();
  }

  @override
  Stream<Message> messages({required User activeUser}) {
    if (_currentUser == null || _currentUser!.id != activeUser.id) {
      connect(activeUser);
    }
    return _messageController.stream;
  }

  @override
  Future<List<Message>> send(List<Message> messages) async {
    final apiUrl = Uri.parse('$baseURL/messages/send');
    final sentMessages = <Message>[];

    for (var message in messages) {
      try {
        print("Preparing to send message: ${message.toJson()}");
        var data = message.toJson();
        if (_encryption != null) {
          print("Encrypting message contents");
          data['contents'] = _encryption.encrypt(message.contents);
        }

        print("Sending HTTP request to $apiUrl");
        final response = await http.post(
          apiUrl,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(data),
        );

        print("Received response with status code: ${response.statusCode}");
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          print("Response data: $responseData");
          sentMessages.add(Message.fromJson(responseData));
        } else {
          throw Exception('Failed to send message. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error sending message: $e');
        print('Message that failed to send: ${message.toJson()}');
        // Add the original message to the list if sending failed
        sentMessages.add(message);
      }
    }

    return sentMessages;
  }
}