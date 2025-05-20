import 'package:chatroom_uikit/chatroom_uikit.dart';
import 'package:chatroom_uikit_example/room_page.dart';
import 'package:flutter/material.dart';

class RoomsListView extends StatefulWidget {
  const RoomsListView({super.key});

  @override
  State<RoomsListView> createState() => _RoomsListViewState();
}

class _RoomsListViewState extends State<RoomsListView> {
  List<ChatRoom> rooms = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      load();
    });
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
          debugPrint(rooms[index].roomId);
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
