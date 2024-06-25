import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:vehicle_me/domain/models/user.dart';
import 'package:vehicle_me/domain/models/receipt.dart';
import 'package:vehicle_me/data/repositories/chat/receipts/receipt_service.dart';

class ReceiptService implements IReceiptService {
  final StreamController<Receipt> _receiptController = StreamController<Receipt>.broadcast();
  IOWebSocketChannel? _channel;
  Timer? _reconnectionTimer;
  User? _currentUser;
  final String baseURL;

  ReceiptService(this.baseURL);

  @override
  Future<void> connect(User user) async {
    _currentUser = user;
    _connectWebSocket();
  }

  void _connectWebSocket() {
    // Remove any 'http://' or 'https://' from the baseURL
    final cleanBaseUrl = baseURL.replaceAll(RegExp(r'(http|https)://'), '');

    // Construct the WebSocket URL
    final wsUrl = Uri.parse('ws://$cleanBaseUrl/receipts/ws/${_currentUser!.id}');

    print('Connecting to WebSocket: $wsUrl'); // Add this line for debugging

    _channel = IOWebSocketChannel.connect(wsUrl);

    _channel!.stream.listen(
          (message) {
        final decodedReceipt = json.decode(message);
        final receipt = Receipt.fromJson(decodedReceipt);
        _receiptController.add(receipt);
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
    _receiptController.close();
  }

  @override
  Stream<Receipt> receipts(User user) {
    if (_currentUser == null || _currentUser!.id != user.id) {
      connect(user);
    }
    return _receiptController.stream;
  }

  @override
  Future<String> send(Receipt receipt) async {
    final apiUrl = Uri.parse('$baseURL/receipts/send');

    try {
      final response = await http.post(
        apiUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(receipt.toJson()),
      );

      if (response.statusCode == 200) {
        return 'Receipt sent successfully';
      } else {
        return 'Failed to send receipt. Status code: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error sending receipt: $e';
    }
  }
}