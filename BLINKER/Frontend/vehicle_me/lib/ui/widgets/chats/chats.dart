import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vehicle_me/domain/state_management/home/chat/message/message_bloc.dart';
import 'package:vehicle_me/colors.dart';
import 'package:vehicle_me/domain/state_management/home/chat/chats_updater_cubit.dart';
import 'package:vehicle_me/themes.dart';
import 'package:vehicle_me/ui/widgets/chats/profile_image.dart';

import '../../../domain/models/chat.dart';

class Chats extends StatefulWidget {
  Chats();

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  var chats = [];

  @override
  void initState() {
    super.initState();
    _updateChatsOnMessageReceived();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatsUpdaterCubit, List<Chat>>(builder: (_, chats) {
      this.chats = chats;
      return _buildListView();
    });
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: EdgeInsets.only(top: 16, right: 16.0),
      itemBuilder: (_, indx) => _chatItem(chats[indx]),
      separatorBuilder: (_, __) => Divider(),
      itemCount: chats.length,
    );
  }

  _chatItem(Chat chat) =>
      ListTile(
        contentPadding: EdgeInsets.only(left: 16.0, right: 16.0),
        leading: ProfileImage(
          imageUrl:
          "https://t4.ftcdn.net/jpg/05/49/98/39/360_F_549983970_bRCkYfk0P6PP5fKbMhZMIb07mCJ6esXL.jpg",
          online: true,
        ),
        title: Text(
          chat.mostRecent!.message.contents,
          style: Theme
              .of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(
            fontWeight: FontWeight.bold,
            color: isLightTheme(context) ? Colors.black87 : kGrayLM,
          ),
        ),
        subtitle: Text(
          chat.mostRecent!.message.contents,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
          style: Theme
              .of(context)
              .textTheme
              .labelSmall
              ?.copyWith(
              color: isLightTheme(context) ? Colors.black87 : Colors.white),
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50.0),
                child: Container(
                  height: 15.0,
                  width: 15.0,
                  color: kBubbleBlue,
                  alignment: Alignment.center,
                  child: chat.unread > 0 ? Text(
                    chat.unread.toString(),
                    style: Theme
                        .of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(
                      color: Colors.white,
                    ),
                  ) : Container(),
                ),
              ),
            ),
            Text(
              chat.mostRecent!.message.time_stamp.toString(),
              style: Theme
                  .of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(
                color:
                isLightTheme(context) ? Colors.black87 : Colors.white,
              ),
            ),
          ],
        ),
      );

  void _updateChatsOnMessageReceived() {
    final chatsCubit = context.read<ChatsUpdaterCubit>();
    context
        .read<MessageBloc>()
        .stream
        .listen((state) async {
      if (state is MessageReceivedSuccess) {
        await chatsCubit.viewmodel.receivedMessage(state.message);
        chatsCubit.chats();
      }
    }
    );
  }
}
