import 'package:chatroom_uikit/chatroom_uikit.dart';
import 'package:flutter/material.dart';

class DemoCustomData extends StatefulWidget {
  const DemoCustomData({required this.child, super.key});

  final Widget child;
  @override
  State<DemoCustomData> createState() => _DemoCustomDataState();
}

class _DemoCustomDataState extends State<DemoCustomData> {
  @override
  void initState() {
    super.initState();
    ChatUIKitProvider.instance.profilesHandler = profilesHandler;
  }

  List<ChatUIKitProfile> profilesHandler(List<ChatUIKitProfile> profiles,
      [String? belongId]) {
    fetchUserData(profiles, belongId);
    return profiles;
  }

  void fetchUserData(
    List<ChatUIKitProfile> profiles, [
    String? belongId,
  ]) async {
    Map<String, UserInfo> infoMap =
        await ChatRoomUIKit.instance.fetchUserInfoByIds(
      profiles.map((p) => p.id).toList(),
    );

    List<ChatUIKitProfile> updatedProfiles = List.from(
      infoMap.keys.map((e) {
        return ChatUIKitProfile.contact(
          id: e,
          nickname: infoMap[e]!.nickName,
          avatarUrl: infoMap[e]!.avatarUrl,
        );
      }),
    );
    ChatUIKitProvider.instance.addProfiles(updatedProfiles);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
