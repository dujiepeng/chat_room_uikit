import 'dart:convert';

import 'package:chatroom_uikit/chatroom_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RoomPage extends StatefulWidget {
  const RoomPage(this.roomId, {super.key});

  final String roomId;
  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  ChatRoomInputBarController inputBarController = ChatRoomInputBarController();
  @override
  void initState() {
    super.initState();
    setup();
  }

  void setup() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ChatRoomUIKit.instance.joinChatRoom(roomId: widget.roomId).then((_) {
        debugPrint('join chat room');
      }).catchError((e) {
        debugPrint('join chat room error: $e');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              ChatRoomUIKit.instance.sendMessage(
                  message: ChatRoomMessage.roomMessage(
                widget.roomId,
                'test',
              ));
            },
            icon: const Icon(Icons.message),
          ),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              inputBarController.hiddenInputBar();
            },
            child: Container(color: Colors.green),
          ),
          Positioned(
            top: MediaQuery.of(context).viewInsets.top + 10,
            left: 0,
            right: 0,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                  child: ChatRoomGlobalMessageView(),
                )
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            height: 84,
            bottom: 300,
            child: ChatRoomShowGiftView(
              roomId: widget.roomId,
            ),
          ),
          Positioned(
            left: 16,
            right: 78,
            height: 204,
            bottom: 90,
            child: ChatRoomMessagesView(roomId: widget.roomId),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: ChatRoomInputBar(
                controller: inputBarController,
                onSend: (msg) {
                  if (msg.trim().isEmpty) {
                    return;
                  }
                  ChatRoomUIKit.instance.sendMessage(
                    message: ChatRoomMessage.roomMessage(widget.roomId, msg),
                  );
                },
                actions: [
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          clipBehavior: Clip.hardEdge,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.0),
                              topRight: Radius.circular(16.0),
                            ),
                          ),
                          builder: (ctx) {
                            return FutureBuilder(
                              future: rootBundle.loadString('data/Gifts.json'),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  Map<String, dynamic> map =
                                      json.decode(snapshot.data!);
                                  List<ChatroomGiftPageController> controllers =
                                      [];
                                  for (var element in map.keys.toList()) {
                                    final controller =
                                        ChatroomGiftPageController(
                                            title: element,
                                            gifts: () {
                                              List<ChatRoomGift> list = [];
                                              map[element].forEach((element) {
                                                ChatRoomGift gift =
                                                    ChatRoomGift.fromJson(
                                                        element);
                                                list.add(gift);
                                              });
                                              return list;
                                            }());
                                    controllers.add(controller);
                                  }
                                  return ChatRoomGiftsView(
                                    giftControllers: controllers,
                                    onSendTap: (gift) {
                                      ChatRoomUIKit.instance.sendMessage(
                                        message: ChatRoomMessage.giftMessage(
                                          widget.roomId,
                                          gift,
                                        ),
                                      );
                                    },
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            );
                          });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Image.asset('images/send_gift.png'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    content = PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        ChatRoomUIKit.instance.leaveChatRoom(widget.roomId).then((_) {
          debugPrint('leave chat room');
        }).catchError((e) {
          debugPrint('leave chat room error: $e');
        });
      },
      child: content,
    );

    return content;
  }
}
