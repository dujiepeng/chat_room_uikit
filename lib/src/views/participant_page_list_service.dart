import 'package:chatroom_uikit/chatroom_uikit.dart';

import 'package:chatroom_uikit/src/widgets/chatroom_dialog.dart';
import 'package:flutter/material.dart';

class ChatroomParticipantListService {
  int pageSize = 20;
  String cursor = '';
  bool fetchAll = false;

  Future<List<String>> loadMoreUsers(String roomId, String ownerId) async {
    if (fetchAll) return Future(() => []);

    try {
      CursorResult<String> result =
          await ChatRoomUIKit.instance.fetchChatRoomMembers(
        roomId: roomId,
        cursor: cursor,
        pageSize: pageSize,
      );

      if (result.cursor?.isEmpty == true) {
        fetchAll = true;
      }
      cursor = result.cursor ?? '';

      return result.data;
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> reloadUsers(String roomId, String ownerId) async {
    fetchAll = false;

    try {
      CursorResult<String> result =
          await ChatRoomUIKit.instance.fetchChatRoomMembers(
        roomId: roomId,
        pageSize: pageSize,
      );

      if (result.cursor?.isEmpty == true) {
        fetchAll = true;
      }
      cursor = result.cursor ?? '';
      result.data.remove(ownerId);
      result.data.insert(0, ownerId);
      return result.data;
    } catch (e) {
      return [];
    }
  }

  List<ChatEventItemAction>? itemMoreActions(
    final BuildContext context,
    final String? userId,
    final String? roomId,
    final String? ownerId,
  ) {
    if (Client.getInstance.currentUserId != ownerId) return null;
    return [
      // TODO:
      // ignore: unrelated_type_equality_checks
      if ('ChatroomContext.instance.muteList.contains(userId)' == true)
        ChatEventItemAction(
          // 国际化
          title: 'ChatroomLocal.bottomSheetUnmute.getString(context)',
          onPressed: (context, roomId, userId, user) async {
            try {
              await ChatRoomUIKit.instance.unMuteChatRoomMembers(
                roomId: roomId,
                unMuteMembers: [userId],
              );
              // ignore: empty_catches
            } catch (e) {}
          },
        ),
      // TODO:
      // ignore: unrelated_type_equality_checks
      if ('!ChatroomContext.instance.muteList.contains(userId)' == true)
        ChatEventItemAction(
          // 国际化
          title: 'ChatroomLocal.bottomSheetMute.getString(context)',
          onPressed: (context, roomId, userId, user) async {
            try {
              await ChatRoomUIKit.instance.muteChatRoomMembers(
                roomId: roomId,
                muteMembers: [userId],
              );
              // ignore: empty_catches
            } catch (e) {}
          },
        ),
      ChatEventItemAction(
        // 国际化
        title: 'ChatroomLocal.memberRemove.getString(context)',
        highlight: true,
        onPressed: (context, roomId, userId, user) async {
          showDialog(
            context: context,
            builder: (context) {
              return ChatRoomDialog(
                title:
                    // 国际化
                    "wantRemove '@${user?.nickname ?? userId}'",
                items: [
                  ChatDialogItem.cancel(
                    onTap: () async {
                      Navigator.of(context).pop();
                    },
                  ),
                  ChatDialogItem.confirm(
                    onTap: () async {
                      Navigator.of(context).pop();
                      try {
                        await ChatRoomUIKit.instance.removeChatRoomMembers(
                          roomId: roomId,
                          members: [userId],
                        );
                        // ignore: empty_catches
                      } catch (e) {}
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    ];
  }

  String title(BuildContext context, String? roomId, String? ownerId) {
    // 国际化
    return 'ChatroomLocal.memberListTitle.getString(context)';
  }
}

class ChatEventItemAction {
  const ChatEventItemAction({
    required this.title,
    this.onPressed,
    this.highlight = false,
  });
  final String title;
  final bool highlight;
  final dynamic Function(
          BuildContext context, String roomId, String userId, dynamic data)?
      onPressed;
}
