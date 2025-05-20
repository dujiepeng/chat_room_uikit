import 'package:chatroom_uikit/chatroom_uikit.dart';
import 'package:chatroom_uikit_example/room_page.dart';
import 'package:flutter/material.dart';

class RoomsListView extends StatefulWidget {
  const RoomsListView({super.key});

  @override
  State<RoomsListView> createState() => _RoomsListViewState();
}

class _RoomsListViewState extends State<RoomsListView>
    with ChatSDKEventsObserver {
  List<ChatRoom> rooms = [];

  @override
  void initState() {
    super.initState();
    ChatSDKService.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      load();
    });
  }

  @override
  void dispose() {
    ChatSDKService.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void onChatSDKEventBegin(ChatSDKEvent event) {
    debugPrint('onChatSDKEventBegin: $event');
  }

  @override
  void onChatSDKEventEnd(ChatSDKEvent event, ChatError? error) {
    debugPrint('onChatSDKEventEnd: $event, error: $error');
  }

  void load() async {
    PageResult<ChatRoom> page =
        await ChatRoomUIKit.instance.fetchPublicChatRoomsFromServer();
    setState(() {
      rooms = page.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Rooms'),
        leading: const SizedBox(),
        actions: [
          IconButton(
            onPressed: load,
            icon: const Icon(Icons.cabin),
          ),
        ],
      ),
      body: ListView.separated(
        itemBuilder: (ctx, index) {
          return ListTile(
            title: Text(rooms[index].name ?? rooms[index].roomId),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => RoomPage(rooms[index].roomId),
                ),
              );
            },
          );
        },
        separatorBuilder: (_, index) {
          return const Divider(
            height: 0.1,
          );
        },
        itemCount: rooms.length,
      ),
    );
  }
}
