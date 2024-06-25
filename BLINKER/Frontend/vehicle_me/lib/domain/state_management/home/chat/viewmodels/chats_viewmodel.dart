import 'package:vehicle_me/domain/models/local_message.dart';
import 'package:vehicle_me/data/datasource/datasource_contract.dart';
import 'package:vehicle_me/domain/models/receipt.dart';
import 'package:vehicle_me/data/repositories/user/user_service_contract.dart';
import '../../../../models/chat.dart';
import 'base_viewmodel.dart';
import 'package:vehicle_me/domain/models/message.dart';


/// Manages the chat-related data and operations.
///
/// This class is responsible for fetching the list of chats, handling received messages,
/// and interacting with the data sources.
class ChatsViewModel extends BaseViewModel {
  IDataSource _datasource;
  IUserService _userService;
  final String token;

  /// Constructs a new [ChatsViewModel] instance.
  ///
  /// [_datasource] - The data source for chat-related operations.
  /// [_userService] - The user service for fetching user information.
  /// [token] - The authentication token.
  ChatsViewModel(this._datasource, this._userService, this.token) : super(_datasource);


  /// Fetches the list of chats and populates the member information.
  ///
  /// Returns the list of [Chat] instances.
  Future<List<Chat>> getChats() async {
    print("fetching chats");
    try {
      final chats = await _datasource.findAllChats();
      await Future.forEach(chats, (Chat chat) async {
        final emails = chat.membersId
            .map((member) => member['email'] as String?)
            .where((email) => email != null)
            .cast<String>()
            .toList();
        if (emails.isNotEmpty) {
          final users = await _userService.fetchUsersByEmails(emails, token);
          chat.members = users;
        }

        // Convert string receipt status to ReceiptStatus enum
        if (chat.mostRecent != null && chat.mostRecent!.receiptStatus != null) {
          chat.mostRecent!.receiptStatus = ReceiptParsing.fromString(chat.mostRecent!.receiptStatus.toString());
        }
      });

      return chats;
    } catch (e) {
      print('Error fetching chats: $e');
      throw e;
    }
  }

  /// Handles the received message.
  ///
  /// [message] - The received message.
  Future<void> receivedMessage(Message message) async {
    final chatId = message.group_id ?? message.sender;
    LocalMessage localMessage =
    LocalMessage(chatId, message, ReceiptStatus.delivered);
    await addMessage(localMessage);
  }
}