import 'package:chat_sdk_service/chat_sdk_service.dart';
import 'package:chat_uikit_theme/chat_uikit_theme.dart';
import 'package:chatroom_uikit/src/chatroom_uikit_service/chatroom_uikit_service.dart';
import 'package:chatroom_uikit/src/widgets/chatroom_message_list_item.dart';
import 'package:flutter/material.dart';

class ChatRoomMessagesView extends StatefulWidget {
  const ChatRoomMessagesView({
    required this.roomId,
    this.onTap,
    this.onLongPress,
    this.itemBuilder,
    super.key,
  });

  final String roomId;

  final Widget Function(Message msg)? itemBuilder;
  final void Function(BuildContext content, Message msg)? onTap;
  final void Function(BuildContext content, Message msg)? onLongPress;
  @override
  State<ChatRoomMessagesView> createState() => _ChatRoomMessagesViewState();
}

class _ChatRoomMessagesViewState extends State<ChatRoomMessagesView>
    with RoomObserver, ChatObserver, MessageObserver, ChatUIKitThemeMixin {
  final scrollController = ScrollController();
  final List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    ChatRoomUIKit.instance.addObserver(this);
  }

  @override
  void dispose() {
    ChatRoomUIKit.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget themeBuilder(BuildContext context, ChatUIKitTheme theme) {
    Widget content = ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      controller: scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        return InkWell(
            key: ValueKey(msg.msgId),
            onLongPress: widget.onLongPress != null
                ? () {
                    widget.onLongPress?.call(context, msg);
                  }
                : null,
            onTap: widget.onTap != null
                ? () {
                    widget.onTap?.call(context, msg);
                  }
                : null,
            child: widget.itemBuilder?.call(msg) ??
                ChatMessageListItemManager.getMessageListItem(msg));
      },
      findChildIndexCallback: (key) {
        final index = messages.indexWhere((element) {
          return element.msgId == (key as ValueKey<String>).value;
        });

        return index > -1 ? index : null;
      },
      separatorBuilder: (context, index) {
        return const SizedBox(height: 4);
      },
    );

    return content;
  }

  @override
  onMessagesReceived(messages) {
    List<Message> localMsgs = List.from(messages);
    localMsgs.removeWhere((element) {
      return element.conversationId != widget.roomId || element.isBroadcast;
    });

    setState(() {
      this.messages.addAll(localMsgs);
      moveToBottom();
    });
  }

  @override
  onMessagesRecalledInfo(
    List<RecallMessageInfo> infos,
    List<Message> replaces,
  ) {
    List<String> needDeleteMsgIds =
        infos.map((info) => info.recallMessageId).toList();

    messages.removeWhere((element) {
      return needDeleteMsgIds.contains(element.msgId);
    });

    setState(() {});
  }

  @override
  void onMessageSendSuccess(String msgId, Message msg) {
    if (msg.conversationId == widget.roomId && !msg.isBroadcast) {
      setState(() {
        messages.add(msg);
        moveToBottom();
      });
    }
  }

  void moveToBottom() {
    if (scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        scrollController.animateTo(scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      });
    }
  }

  @override
  void onMemberJoinedFromChatRoom(
    String roomId,
    String participant,
    String? ext,
  ) {
    debugPrint(
        'onMemberJoinedFromChatRoom roomId: $roomId, participant: $participant, ext: $ext');
  }
}
