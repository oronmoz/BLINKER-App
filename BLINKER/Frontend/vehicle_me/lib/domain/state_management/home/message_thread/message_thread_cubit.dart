import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vehicle_me/domain/models/local_message.dart';
import 'package:vehicle_me/domain/state_management/home/chat/viewmodels/chat_viewmodel.dart';

class MessageThreadCubit extends Cubit<List<LocalMessage>> {
  final ChatViewModel viewModel;
  MessageThreadCubit(this.viewModel): super([]);

  Future<void> messagesRefresh(String chatID) async {
    print("Fetching messages for chat: $chatID");
    final messages = await viewModel.getMessages(chatID);
    print("Emitting ${messages.length} messages");
    emit(messages);
  }

  // Add this method
  void addMessage(LocalMessage message) {
    print("Adding message to UI: ${message.message.contents}");
    final updatedMessages = List<LocalMessage>.from(state)..add(message);
    emit(updatedMessages);
  }
}
