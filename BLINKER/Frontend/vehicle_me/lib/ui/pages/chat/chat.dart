import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vehicle_me/domain/state_management/home/chat/chat_cubit.dart';
import 'package:vehicle_me/domain/state_management/home/chat/chat_event.dart';
import 'package:vehicle_me/domain/state_management/home/chat/groups/group_chat_bloc.dart';
import 'package:vehicle_me/domain/state_management/home/chat/home_cubit.dart';
import 'package:vehicle_me/domain/state_management/home/chat/receipt/receipt_bloc.dart';
import 'package:vehicle_me/domain/state_management/home/home_bloc.dart';

import '../../../colors.dart';
import '../../../domain/models/user.dart';
import '../../../domain/models/chat.dart';
import '../../../domain/state_management/home/chat/chat_state.dart';
import '../../../domain/state_management/home/chat/chats_updater_cubit.dart';
import '../../../domain/state_management/home/chat/message/message_bloc.dart';
import '../../../domain/state_management/home/chat/typing_notification/typing_notification_bloc.dart';
import '../../../domain/state_management/home/message_thread/message_thread_cubit.dart';
import '../../../themes.dart';


class ChatScreen extends StatefulWidget {
  final User activeUser;

  const ChatScreen({required this.activeUser,
    required MessageBloc messageBloc,
    required ChatsUpdaterCubit chatsCubit,
    required TypingNotificationBloc typingNotificationBloc,
    required MessageThreadCubit messageThreadCubit,
    required ReceiptBloc receiptBloc,
    required GroupChatBloc groupChatBloc});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChatsUpdaterCubit>().chats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LINKER'),
        actions: [
          IconButton(
            icon: Icon(Icons.add_comment_sharp, size: 24.0, color: kBubblePurple),
            onPressed: () {
              ChatBloc _chatBloc = context.read<ChatBloc>();
              ChatsUpdaterCubit _updater = context.read<ChatsUpdaterCubit>();
              showSearch(
                context: context,
                delegate: VehicleSearch(_chatBloc, _updater, widget.activeUser),
              ).then((String? result) {
                if (result != null && result.isNotEmpty) {
                  final selectedChat = _updater.state.firstWhere((chat) => chat.id == result);
                  _navigateToMessageThread(context, selectedChat, widget.activeUser, selectedChat.members ?? []);
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.search, size: 24.0, color: kBubblePurple),
            onPressed: () {
              final cubit = context.read<ChatsUpdaterCubit>();
              showSearch(
                context: context,
                delegate: ChatSearchDelegate(cubit, widget.activeUser),
              ).then((String? result) {
                if (result != null && result.isNotEmpty) {
                  final selectedChat = cubit.state.firstWhere((chat) => chat.id == result);
                  _navigateToMessageThread(context, selectedChat, widget.activeUser, selectedChat.members ?? []);
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.settings, size: 24.0, color: kBubblePurple),
            onPressed: () {
              // TODO: Implement settings functionality
            },
          ),
        ],
      ),
      body: BlocBuilder<ChatsUpdaterCubit, List<Chat>>(
        builder: (context, chats) {
          if (chats.isEmpty) {
            return Container();
          }
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ListTile(
                title: Text(chat.name ?? 'Chat ${index + 1}'),
                subtitle: Text(chat.mostRecent?.message.contents ?? 'No messages yet'),
                onTap: () {
                  _navigateToMessageThread(context, chat, widget.activeUser, chat.members ?? []);
                },
              );
            },
          );
        },
      ),
    );
  }



  void _navigateToMessageThread(BuildContext context, Chat chat, User me, List<User> receivers) {
    Navigator.pushReplacementNamed(
      context,
      'message_thread',
      arguments: {
        'receivers': receivers,
        'me': me,
        'chat': chat,
      },
    );
  }
}

class VehicleSearch extends SearchDelegate<String> {
  final ChatsUpdaterCubit chatsUpdaterCubit;
  final ChatBloc chatBloc;
  final User user;
  bool _searchStopped = false;

  VehicleSearch(this.chatBloc, this.chatsUpdaterCubit, this.user);

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  void stopSearch(){
    _searchStopped = true;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty || _searchStopped) {
      return Center(child: Text('Please enter a vehicle number'));
    }

    // Add the event immediately when building results
    chatBloc.add(ChatCreate([query]));

    return BlocListener<ChatBloc, ChatState>(
      bloc: chatBloc,
      listener: (context, state) {
        if (state is ChatFetchSuccess) {
          stopSearch();
          chatsUpdaterCubit.chats(); // Update the chats list
          Navigator.of(context).pushReplacementNamed(
            'message_thread',
            arguments: {
              'receivers': state.chat.members,
              'me': user,
              'chat': state.chat,
            },
          ).then((_) => close(context, ''));
        } else if (state is ChatError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.error}')),
          );
          // Instead of adding a new event, just close the search
          close(context, '');
        }
      },
      child: Center(child: CircularProgressIndicator()),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}

class ChatSearchDelegate extends SearchDelegate<String> {
  final ChatsUpdaterCubit chatsCubit;
  final User activeUser;

  ChatSearchDelegate(this.chatsCubit, this.activeUser);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final chats = chatsCubit.state;
    final trimmedLowerQuery = query.trim().toLowerCase();
    final filteredChats = chats.where((chat) {
      return chat.name?.toLowerCase().contains(trimmedLowerQuery) ?? false ||
          chat.members!.any((member) =>
          member.email.toLowerCase().contains(trimmedLowerQuery) ||
              (member.vehicle.carId.toLowerCase().contains(trimmedLowerQuery)));
    }).toList();

    return ListView.builder(
      itemCount: filteredChats.length,
      itemBuilder: (context, index) {
        final chat = filteredChats[index];
        return ListTile(
          title: Text(chat.name ?? 'Chat ${index + 1}'),
          subtitle: Text(chat.mostRecent?.message.contents ?? 'No messages yet'),
          onTap: () {
            close(context, chat.id);
          },
        );
      },
    );
  }
}