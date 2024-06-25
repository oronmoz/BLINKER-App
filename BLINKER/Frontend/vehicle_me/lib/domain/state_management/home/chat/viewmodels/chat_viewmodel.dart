import 'package:vehicle_me/domain/models/local_message.dart';
import 'package:vehicle_me/domain/models/receipt.dart';
import '../../../../../data/datasource/datasource_contract.dart';
import 'base_viewmodel.dart';
import 'package:vehicle_me/domain/models/message.dart';

class ChatViewModel extends BaseViewModel {
  IDataSource _datasource;
  late String _chatId = '';
  int otherMessages = 0;

  String get chatId => _chatId;

  ChatViewModel(this._datasource, this.otherMessages) : super(_datasource);

  Future<List<LocalMessage>> getMessages(String chatId) async {
    final messages = await _datasource.findMessages(chatId);
    print("Retrieved ${messages.length} messages for chat: $chatId");
    _chatId = chatId; // Set _chatId regardless of messages being empty or not
    return messages;
  }

  Future<void> sentMessage(Message message) async {
    final chatId = message.group_id ?? message.recipient;
    LocalMessage localMessage = LocalMessage(chatId, message, ReceiptStatus.sent);
    if (_chatId.isNotEmpty) {
      print("Sending message: ${message.contents} to chat: $_chatId");
      await _datasource.addMessage(localMessage);
    } else {
      _chatId = localMessage.chat_id;
      await addMessage(localMessage);
      print("Message added to local storage");
    }
  }

  Future<void> receivedMessage(Message message) async {
    final chatId = message.group_id ?? message.sender;
    if (chatId == null) {
      throw Exception('Invalid message: no valid chatId found');
    }
    LocalMessage localMessage = LocalMessage(chatId, message, ReceiptStatus.delivered);
    if (_chatId.isEmpty) {
      _chatId = localMessage.chat_id;
    }
    if (localMessage.chat_id != _chatId) otherMessages++;
    await addMessage(localMessage);
  }

  Future<void> updateMessageReceipt(Receipt receipt) async {
    await _datasource.updateMessageReceipt(receipt.messageID, receipt.status);
  }

}