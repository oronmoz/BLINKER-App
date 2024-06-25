import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:vehicle_me/colors.dart';
import 'package:vehicle_me/domain/state_management/home/chat/chats_updater_cubit.dart';
import 'package:vehicle_me/utils/color_generator.dart';

import '../../../domain/models/chat.dart';
import '../../../domain/models/local_message.dart';
import '../../../domain/models/message.dart';
import '../../../domain/models/receipt.dart';
import '../../../domain/models/typing_event.dart';
import '../../../domain/models/user.dart';
import '../../../domain/state_management/home/chat/message/message_bloc.dart';
import '../../../domain/state_management/home/chat/receipt/receipt_bloc.dart';
import '../../../domain/state_management/home/chat/typing_notification/typing_notification_bloc.dart';
import '../../../domain/state_management/home/message_thread/message_thread_cubit.dart';
import '../../../themes.dart';
import '../../widgets/chats/recipient_message.dart';
import '../../widgets/chats/sender_message.dart';
import '../../widgets/shared/header_status.dart';

class MessageThread extends StatefulWidget {
  final List<User> members;
  final User me;
  final Chat chat;
  final MessageBloc messageBloc;
  final TypingNotificationBloc typingNotificationBloc;
  final ChatsUpdaterCubit chatsCubit;

  const MessageThread(this.members, this.me, this.messageBloc, this.chatsCubit,
      this.typingNotificationBloc, this.chat, {Key? key})
      : super(key: key);

  @override
  _MessageThreadState createState() => _MessageThreadState();
}

class _MessageThreadState extends State<MessageThread> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();
  String chatId = '';
  late List<User> receivers;
  late List<LocalMessage> messages = [];
  Timer? _startTypingTimer;
  Timer? _stopTypingTimer;

  @override
  void initState() {
    super.initState();
    receivers = widget.members.where((e) => e.email != widget.me.email).toList();

    _updateOnMessageReceived();
    _updateOnReceiptReceived();


    context.read<MessageBloc>().add(MessageSubscribed(widget.me));
    context.read<ReceiptBloc>().add(ReceiptEvent.onSubscribed(widget.me));
    widget.typingNotificationBloc.add(
      TypingNotificationEvent.onSubscribed(widget.me,
          usersWithChat: receivers.map((e) => e.email).toList()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
                icon: Icon(Icons.arrow_back_ios_rounded,
                    color: isLightTheme(context) ? Colors.black : Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                }),
            Expanded(
                child: BlocBuilder<TypingNotificationBloc,
                    TypingNotificationState>(
                  bloc: widget.typingNotificationBloc,
                  builder: (_, state) {
                    return HeaderStatus(
                      widget.chat.name ?? receivers.first.email,
                      widget.chat.type == ChatType.individual
                          ? receivers.first.photo_url ?? ''
                          : '',
                      widget.chat.type == ChatType.individual
                          ? receivers.first.is_active
                          : false,
                      description: widget.chat.type == ChatType.individual
                          ? 'last seen ${receivers.first.last_seen ?? 'unknown'}'
                          : receivers
                          .fold<String>('', (p, e) => p + ', ' + e.email)
                          .replaceFirst(',', '')
                          .trim(),
                      typing: _getTypingStatus(state),
                    );
                  },
                ))
          ],
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: MultiBlocListener(
        listeners: [
          BlocListener<MessageBloc, MessageState>(
            bloc: widget.messageBloc,
            listener: (context, state) {
              if (state is MessageSentSuccess) {
                print("Message sent successfully");
                // Handle successful message sending
                for (var message in state.messages) {
                  context.read<MessageThreadCubit>().addMessage(
                      LocalMessage(chatId, message, ReceiptStatus.sent));
                }
                // Trigger UI update by calling getMessages
                context.read<MessageThreadCubit>().viewModel.getMessages(chatId);
                widget.chatsCubit.chats();
              } else if (state is MessageSendFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to send message: ${state.error}')),
                );
                print("Message added to thread: ${messages[0].message.contents}");
              }
            },
          ),
          BlocListener<TypingNotificationBloc, TypingNotificationState>(
            bloc: widget.typingNotificationBloc,
            listener: (context, state) {
              if (state is TypingNotificationSentFailure) {
                print('Failed to send typing notification: ${state.error}');
              }
            },
          ),
        ],
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Column(children: [
            Flexible(
              flex: 6,
              child: BlocBuilder<MessageThreadCubit, List<LocalMessage>>(
                builder: (__, messages) {
                  this.messages = messages;
                  if (this.messages.isEmpty)
                    return Container(
                      alignment: Alignment.topCenter,
                      padding: EdgeInsets.only(top: 30),
                      color: Colors.transparent,
                      child: widget.chat.type == ChatType.group
                          ? DecoratedBox(
                        decoration: BoxDecoration(
                            color: kCreamLM.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text('Group created',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.white)),
                        ),
                      )
                          : Container(),
                    );
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _scrollToEnd());
                  return _buildListOfMessages();
                },
              ),
            ),
            Expanded(
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: isLightTheme(context) ? kBubbleGreen : kDarkGrayDM,
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, -3),
                      blurRadius: 6.0,
                      color: Colors.black12,
                    ),
                  ],
                ),
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _buildMessageInput(context),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Container(
                          height: 45.0,
                          width: 45.0,
                          child: RawMaterialButton(
                              fillColor: kGrayDM,
                              shape: new CircleBorder(),
                              elevation: 5.0,
                              child: Icon(
                                Icons.send,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _sendMessage();
                              }),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }

  _buildListOfMessages() => BlocBuilder<MessageThreadCubit, List<LocalMessage>>(
    builder: (context, messages) {
      print("Building list with ${messages.length} messages");
      return ListView.builder(
        padding: EdgeInsets.only(top: 16, left: 16.0, bottom: 20),
        itemBuilder: (__, idx) {
          if (receivers.any((e) => e.email == messages[idx].message.sender)) {
            _sendReceipt(messages[idx]);
            final receiver = receivers.firstWhere(
                    (e) => e.email == messages[idx].message.sender);

            final String color = widget.chat.membersId
                .firstWhere((e) => e.containsKey(receiver.email))
                .values
                .first;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ReceiverMessage(
                messages[idx],
                receiver,
                widget.chat.type,
                color: ChatType.group == widget.chat.type
                    ? Color(int.tryParse(color) ??
                    Theme.of(context).primaryColor.value)
                    : RandomColorGenerator.getColorForUser(
                    messages[idx], receiver),
              ),
            );
          } else {
            return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: SenderMessage(messages[idx]));
          }
        },
        itemCount: messages.length,
        controller: _scrollController,
        physics: AlwaysScrollableScrollPhysics(),
        addAutomaticKeepAlives: true,
      );
    },
  );

  _buildMessageInput(BuildContext context) {
    final _border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(90.0)),
      borderSide: isLightTheme(context)
          ? BorderSide.none
          : BorderSide(color: Colors.grey.withOpacity(0.3)),
    );

    return Focus(
      onFocusChange: (focus) {
        if (_startTypingTimer == null || focus) {
          return;
        }
        _stopTypingTimer?.cancel();
        _dispatchTyping(Typing.stop);
      },
      child: TextFormField(
        controller: _textEditingController,
        textInputAction: TextInputAction.newline,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        style: Theme.of(context).textTheme.bodySmall,
        cursorColor: kCreamLM,
        onChanged: _sendTypingNotification,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
          enabledBorder: _border,
          filled: true,
          fillColor:
          isLightTheme(context) ? kCreamLM.withOpacity(0.1) : kDarkGrayDM,
          focusedBorder: _border,
        ),
      ),
    );
  }

  void _updateOnMessageReceived() {
    final messageThreadCubit = context.read<MessageThreadCubit>();
    final receiptBloc = context.read<ReceiptBloc>();
    if (chatId.isNotEmpty) messageThreadCubit.viewModel.getMessages(chatId);
    widget.messageBloc.stream.listen((state) async {
      if (state is MessageReceivedSuccess) {
        await messageThreadCubit.viewModel.receivedMessage(state.message);
        final receipt = Receipt(
          recipient: state.message.sender,
          messageID: state.message.id!,
          status: ReceiptStatus.read,
          timeStamp: state.message.time_stamp,
        );
        receiptBloc.add(ReceiptEvent.onReceiptSent(receipt));
      }
      if (state is MessageSentSuccess) {
        for (var message in state.messages) {
          await messageThreadCubit.viewModel.sentMessage(message);
          widget.chatsCubit.chats();
        }
      }
      if (chatId.isEmpty) {
        await messageThreadCubit.viewModel.getMessages(chatId);
        chatId = widget.chat.id;
      }
    });
  }

  void _updateOnReceiptReceived() {
    final messageThreadCubit = context.read<MessageThreadCubit>();
    context.read<ReceiptBloc>().stream.listen((state) async {
      if (state is ReceiptReceiveSuccess) {
        await messageThreadCubit.viewModel.updateMessageReceipt(state.receipt);
        messageThreadCubit.viewModel.getMessages(chatId);
        widget.chatsCubit.chats();
      }
    });
  }

  _sendMessage() async {
    if (_textEditingController.text.trim().isEmpty) return;

    final message = Message(
      group_id: widget.chat.type == ChatType.group ? widget.chat.id : null,
      sender: widget.me.email,
      recipient: receivers.first.email,
      time_stamp: DateTime.now().toIso8601String(),
      contents: _textEditingController.text,
    );

    widget.messageBloc.add(MessageSent([message]));

    _textEditingController.clear();
    _startTypingTimer?.cancel();
    _stopTypingTimer?.cancel();

    _dispatchTyping(Typing.stop);
  }

  void _dispatchTyping(Typing event) {
    final chatId = widget.chat.type == ChatType.group ? this.chatId : widget.me.email;
    final List<TypingEvent> typingEvents = [];

    for (final receiver in receivers) {
      if (receiver.email != widget.me.email) {
        final typingEvent = TypingEvent(
          chatId: chatId,
          sender: widget.me.email,
          recipient: receiver.email,
          event: event,
        );
        typingEvents.add(typingEvent);
      }
    }

    widget.typingNotificationBloc.add(TypingNotificationEvent.onTypingEventSent(typingEvents));
  }



  void _sendTypingNotification(String text) {
    if (text.trim().isEmpty) {
      _dispatchTyping(Typing.stop);
      return;
    }

    // Reset timers on each character typed
    _startTypingTimer?.cancel();
    _stopTypingTimer?.cancel();

    _dispatchTyping(Typing.start);

    _startTypingTimer = Timer(Duration(seconds: 5), () {});

    _stopTypingTimer =
        Timer(Duration(seconds: 6), () => _dispatchTyping(Typing.stop));
  }

  _scrollToEnd() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  _sendReceipt(LocalMessage message) async {
    if (message.receiptStatus == ReceiptStatus.read) return;
    final receipt = Receipt(
      recipient: message.message.recipient,
      messageID: message.id,
      status: ReceiptStatus.read,
      timeStamp: DateTime.now().toIso8601String(),
    );
    if (widget.chat.type == ChatType.individual) {
      context.read<ReceiptBloc>().add(ReceiptEvent.onReceiptSent(receipt));
    }
    await context
        .read<MessageThreadCubit>()
        .viewModel
        .updateMessageReceipt(receipt);
  }

  String? _getTypingStatus(TypingNotificationState state) {
    if (state is TypingNotificationReceivedSuccess &&
        state.event.event == Typing.start &&
        state.event.sender == chatId) {
      if (widget.chat.type == ChatType.individual) {
        return 'typing...';
      } else {
        return '${receivers.firstWhere((e) => e.email == state.event.recipient).email} is typing';
      }
    }
    return null;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _stopTypingTimer?.cancel();
    _startTypingTimer?.cancel();
    super.dispose();
  }
}