import 'package:flutter/material.dart';
import 'package:vehicle_me/ui/widgets/chats/chats.dart';
import '../../../domain/models/user.dart';

abstract class IHomeRouter {
  Future<void> onShowMessageThread(
      BuildContext context, User receiver, User activeUser,
      {String? chatID});

  Future<void> onShowChats(BuildContext context);
}



class HomeRouter implements IHomeRouter {
  final Widget Function(User receiver, User activeUser, {String? chatID})
      showMessageThread;

  final Widget chatsWidget;
  HomeRouter({required this.showMessageThread, required this.chatsWidget});

  @override
  Future<void> onShowMessageThread(
      BuildContext context, User receiver, User activeUser,
      {String? chatID}) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => showMessageThread(receiver, activeUser, chatID: chatID),
      ),
    );
  }

  @override
  Future<void> onShowChats(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => chatsWidget,
      ),
    );
  }
}

