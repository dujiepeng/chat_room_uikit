import 'package:chatroom_uikit/chatroom_uikit.dart';

mixin ChatRoomUIKitRoomActions on ChatSDKService {
  @override
  Future<void> joinChatRoom({
    required String roomId,
    bool leaveOther = true,
    String? ext,
  }) async {
    try {
      await super.joinChatRoom(
        roomId: roomId,
        leaveOther: leaveOther,
        ext: ext,
      );
      final message = ChatRoomMessage.joinedMessage(roomId);
      Future.delayed(const Duration(milliseconds: 100), () {
        ChatSDKService.instance.sendMessage(message: message);
      });
    } catch (e) {
      rethrow;
    }
  }
}
