import 'package:chatroom_uikit/chatroom_uikit.dart';
import 'package:chatroom_uikit_example/room_page.dart';
import 'package:flutter/material.dart';

class RoomsListView extends StatefulWidget {
  const RoomsListView({super.key});

  @override
  State<RoomsListView> createState() => _RoomsListViewState();
}

class _RoomsListViewState extends State<RoomsListView>
    with ChatUIKitThemeMixin {
  List<ChatRoom> list = [];
  ValueNotifier<bool> loading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch chat rooms from the server or local database
      fetchChatRooms();
    });
  }

  void fetchChatRooms() async {
    try {
      loading.value = true;
      PageResult<ChatRoom> result =
          await ChatRoomUIKit.instance.fetchPublicChatRoomsFromServer();
      List<String> roomIds = result.data.map((e) => e.roomId).toList();
      list.removeWhere((room) => roomIds.contains(room.roomId));
      list.addAll(result.data);
      loading.value = false;
    } catch (e) {
      loading.value = false;
    }
  }

  @override
  Widget themeBuilder(BuildContext context, ChatUIKitTheme theme) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Rooms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              fetchChatRooms();
            },
          ),
        ],
      ),
      body: Center(
        child: ValueListenableBuilder<bool>(
          valueListenable: loading,
          builder: (context, isLoading, child) {
            if (isLoading) {
              return const CircularProgressIndicator();
            }
            return ListView.separated(
              separatorBuilder: (context, index) => const Divider(),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final chatRoom = list[index];
                return ListTile(
                  title: Text(chatRoom.name ?? chatRoom.roomId),
                  onTap: () {
                    // Navigate to chat room details
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RoomPage(chatRoom),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

//
