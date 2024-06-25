import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/chat.dart';
import '../chat/viewmodels/chats_viewmodel.dart';
class ChatsUpdaterCubit extends Cubit<List<Chat>>{
  final ChatsViewModel viewmodel;

  ChatsUpdaterCubit(this.viewmodel) : super([]);

  Future<void> chats() async{
    final chats = await viewmodel.getChats();
    emit(chats);
  }

}