import 'package:chatroom_uikit/chatroom_uikit.dart';
import 'package:chatroom_uikit/src/utils/chatroom_image_loader.dart';
import 'package:chatroom_uikit/src/widgets/chat_bottom_sheet_background.dart';
import 'package:chatroom_uikit/src/widgets/chatroom_uikit_avatar.dart';
import 'package:chatroom_uikit/src/widgets/custom_tab_indicator.dart';
import 'package:flutter/material.dart';

class ChatRoomUIKitMutesController extends ChatRoomUIKitMembersInterface {
  ChatRoomUIKitMutesController(super.title, {super.itemBuilder});
  String? cursor;
  int pageNumber = 1;

  @override
  Future<List<String>> loadData() async {
    try {
      List<String> result = await ChatRoomUIKit.instance
          .fetchChatRoomMuteList(roomId: _state!.roomId, pageNum: pageNumber);
      pageNumber++;
      firstLoading.value = false;
      return result;
    } catch (e) {
      firstLoading.value = false;
      debugPrint('Error fetching chat room members: $e');
      return [];
    }
  }

  @override
  Future<List<String>> reloadData() async {
    try {
      pageNumber = 1;
      List<String> result = await ChatRoomUIKit.instance
          .fetchChatRoomMuteList(roomId: _state!.roomId, pageNum: pageNumber);
      pageNumber;
      firstLoading.value = false;
      return result;
    } catch (e) {
      firstLoading.value = false;
      debugPrint('Error fetching chat room members: $e');
      return [];
    }
  }
}

class ChatRoomUIKitMembersController extends ChatRoomUIKitMembersInterface {
  ChatRoomUIKitMembersController(super.title, {super.itemBuilder});
  String? cursor;

  @override
  Future<List<String>> loadData() async {
    try {
      CursorResult<String> result =
          await ChatRoomUIKit.instance.fetchChatRoomMembers(
        roomId: _state!.roomId,
        cursor: cursor,
      );
      cursor = result.cursor;
      firstLoading.value = false;
      return result.data;
    } catch (e) {
      debugPrint('Error fetching chat room members: $e');
      return [];
    }
  }

  @override
  Future<List<String>> reloadData() async {
    try {
      cursor = null;
      CursorResult<String> result =
          await ChatRoomUIKit.instance.fetchChatRoomMembers(
        roomId: _state!.roomId,
        cursor: cursor,
      );
      cursor = result.cursor;
      firstLoading.value = false;
      return result.data;
    } catch (e) {
      debugPrint('Error fetching chat room members: $e');
      return [];
    }
  }
}

typedef ChatRoomUIKitMembersListItemBuilder = Widget? Function(
  BuildContext context,
  ChatUIKitProfile profile,
  Function? onMoreAction,
);

abstract class ChatRoomUIKitMembersInterface {
  ChatRoomUIKitMembersInterface(this.title, {this.itemBuilder});
  final String title;
  final ChatRoomUIKitMembersListItemBuilder? itemBuilder;
  ValueNotifier firstLoading = ValueNotifier(true);

  _ChatRoomMemberListViewState? _state;
  void _attach(_ChatRoomMemberListViewState state) {
    _state = state;
  }

  void _detach() {
    _state = null;
  }

  Future<List<String>> loadData();

  Future<List<String>> reloadData();
}

class ChatRoomUIKitMembersView extends StatefulWidget {
  const ChatRoomUIKitMembersView({
    required this.roomId,
    required this.ownerId,
    required this.controllers,
    super.key,
  });
  final String roomId;
  final String ownerId;
  final List<ChatRoomUIKitMembersInterface> controllers;

  @override
  State<ChatRoomUIKitMembersView> createState() =>
      _ChatRoomUIKitMembersViewState();
}

class _ChatRoomUIKitMembersViewState extends State<ChatRoomUIKitMembersView>
    with SingleTickerProviderStateMixin, ChatUIKitThemeMixin {
  late List<ChatRoomUIKitMembersInterface> controllers;
  late TabController _tabController;

  ScrollController scrollController = ScrollController();

  ValueNotifier onSearch = ValueNotifier(false);

  String get roomId => widget.roomId;
  @override
  void initState() {
    super.initState();

    controllers = widget.controllers;
    _tabController = TabController(
      vsync: this,
      length: widget.controllers.length,
    );
  }

  @override
  Widget themeBuilder(BuildContext context, ChatUIKitTheme theme) {
    Widget content = ValueListenableBuilder(
        valueListenable: onSearch,
        builder: (context, value, child) {
          Widget content = ChatBottomSheetBackground(
            showGrip: !value,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: value ? 0 : 44,
                  child: TabBar(
                    tabAlignment: TabAlignment.center,
                    dividerColor: Colors.transparent,
                    indicator: CustomTabIndicator(
                      radius: 2,
                      color: theme.color.isDark
                          ? theme.color.primaryColor6
                          : theme.color.primaryColor5,
                      size: value ? Size.zero : const Size(28, 4),
                    ),
                    controller: _tabController,
                    labelStyle: TextStyle(
                      fontWeight: theme.font.titleMedium.fontWeight,
                      fontSize: theme.font.titleMedium.fontSize,
                    ),
                    labelColor: (theme.color.isDark
                        ? theme.color.neutralColor98
                        : theme.color.neutralColor1),
                    isScrollable: true,
                    tabs: widget.controllers
                        .map((controller) => Tab(text: controller.title))
                        .toList(),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: widget.controllers.map((controller) {
                      return ChatRoomMemberListView(
                        roomId: roomId,
                        controller: controller,
                        ownerId: widget.ownerId,
                        onSearch: (isSearch) {
                          onSearch.value = isSearch;
                        },
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          );

          content = AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            height: value
                ? MediaQuery.of(context).size.height - 54
                : MediaQuery.of(context).size.height * 3 / 5,
            child: content,
          );
          return content;
        });

    return content;
  }
}

class ChatRoomMemberListView extends StatefulWidget {
  const ChatRoomMemberListView({
    required this.roomId,
    required this.controller,
    this.ownerId,
    this.onSearch,
    super.key,
  });
  final String roomId;
  final String? ownerId;
  final void Function(bool onSearch)? onSearch;
  final ChatRoomUIKitMembersInterface controller;

  @override
  State<ChatRoomMemberListView> createState() => _ChatRoomMemberListViewState();
}

class _ChatRoomMemberListViewState extends State<ChatRoomMemberListView>
    with AutomaticKeepAliveClientMixin {
  List<ChatUIKitProfile> members = [];
  ScrollController scrollController = ScrollController();
  ValueNotifier isSearch = ValueNotifier(false);
  String get roomId => widget.roomId;
  bool loadingMore = false;
  FocusNode focusNode = FocusNode();
  String keyword = '';
  List<ChatUIKitProfile> showUsers = [];

  bool isOwner = false;
  @override
  void initState() {
    super.initState();
    widget.controller._attach(this);
    isOwner = widget.ownerId == ChatRoomUIKit.instance.currentUserId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController = ScrollController()
        ..addListener(() async {
          if (isSearch.value) return;
          if (scrollController.position.maxScrollExtent <
              scrollController.position.pixels + 40) {
            if (loadingMore) {
              return;
            }
            loadingMore = true;
            loadData();
            loadingMore = false;
          }
        });

      loadData();
    });
  }

  @override
  void dispose() {
    widget.controller._detach();
    scrollController.dispose();
    super.dispose();
  }

  void loadData() async {
    List<String> list = await widget.controller.loadData();
    List<ChatUIKitProfile> temp =
        list.map((userId) => ChatUIKitProfile.contact(id: userId)).toList();
    Map<String, ChatUIKitProfile> map =
        ChatUIKitProvider.instance.getProfiles(temp, belongId: widget.roomId);
    members.removeWhere((element) => map.values.contains(element.id));
    members.addAll(map.values);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> reloadData() async {
    List<String> list = await widget.controller.reloadData();
    List<ChatUIKitProfile> temp =
        list.map((userId) => ChatUIKitProfile.contact(id: userId)).toList();
    Map<String, ChatUIKitProfile> map =
        ChatUIKitProvider.instance.getProfiles(temp, belongId: widget.roomId);
    members.removeWhere((element) => map.values.contains(element.id));
    members.addAll(map.values);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = ChatUIKitTheme.instance;
    Widget content = ListView.separated(
      itemBuilder: (context, index) {
        ChatUIKitProfile profile = members[index];
        showUsers.add(profile);
        return widget.controller.itemBuilder?.call(context, profile, null) ??
            ChatRoomUIKitMemberListTitle(
              profile: profile,
              onMoreAction: isOwner && profile.id != widget.ownerId
                  ? () {
                      Navigator.of(context).pop();
                    }
                  : null,
            );
      },
      controller: scrollController,
      separatorBuilder: (context, index) => Divider(
        indent: 68,
        color: (theme.color.isDark
            ? theme.color.neutralColor1
            : theme.color.neutralColor9),
      ),
      cacheExtent: 100,
      itemCount: members.length,
    );

    if (!isSearch.value) {
      content = RefreshIndicator(
        onRefresh: () async {
          await reloadData();
        },
        child: content,
      );
    }

    content = Column(
      children: [
        searchBar(),
        () {
          if (isSearch.value != true || keyword.isNotEmpty) {
            if (members.isEmpty) {
              return Align(
                heightFactor: 1.5,
                child: ChatRoomImageLoader.empty(),
              );
            } else {
              return Expanded(child: content);
            }
          } else {
            return Container();
          }
        }(),
      ],
    );

    content = PopScope(
      child: content,
      onPopInvokedWithResult: (didPop, _) async {
        focusNode.unfocus();
      },
    );

    return content;
  }

  Widget firstLoadingWidget() {
    return const SizedBox(
      height: 30,
      width: 30,
      child: Center(
        child: SafeArea(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  Widget searchBar() {
    // TODO: 搜索
    return const SizedBox();
    Widget content;
    final theme = ChatUIKitTheme.instance;
    content = ValueListenableBuilder(
      valueListenable: isSearch,
      builder: (context, value, child) {
        Widget content;
        if (value) {
          content = Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 4, 0, 4),
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: (theme.color.isDark
                        ? theme.color.neutralColor2
                        : theme.color.neutralColor95),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 6, 4, 8),
                        child: ChatRoomImageLoader.search(
                          size: 20,
                          color: (theme.color.isDark
                              ? theme.color.neutralColor4
                              : theme.color.neutralColor6),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          style: TextStyle(
                              color: theme.color.isDark
                                  ? theme.color.neutralColor98
                                  : theme.color.neutralColor1,
                              fontWeight: theme.font.bodyLarge.fontWeight,
                              fontSize: theme.font.bodyLarge.fontSize),
                          keyboardAppearance: theme.color.isDark
                              ? Brightness.dark
                              : Brightness.light,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(
                                borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: -8,
                            ),
                            // TODO : 国际化
                            hintText: '搜索',
                            hintStyle: TextStyle(
                              fontWeight: theme.font.bodyLarge.fontWeight,
                              fontSize: theme.font.bodyLarge.fontSize,
                              color: (theme.color.isDark
                                  ? theme.color.neutralColor4
                                  : theme.color.neutralColor6),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              keyword = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(19, 4, 20, 4),
                child: InkWell(
                  onTap: () {
                    keyword = '';
                    showUsers.clear();
                    isSearch.value = false;
                    widget.onSearch?.call(false);
                    focusNode.unfocus();
                  },
                  child: Text(
                    // TODO : 国际化
                    '取消',
                    style: TextStyle(
                      color: (theme.color.isDark
                          ? theme.color.neutralColor6
                          : theme.color.primaryColor5),
                      fontWeight: theme.font.labelMedium.fontWeight,
                      fontSize: theme.font.labelMedium.fontSize,
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          content = Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: (theme.color.isDark
                  ? theme.color.neutralColor2
                  : theme.color.neutralColor95),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChatRoomImageLoader.search(
                  size: 22,
                  color: (theme.color.isDark
                      ? theme.color.neutralColor4
                      : theme.color.neutralColor6),
                ),
                const SizedBox(width: 5.83),
                Text(
                  // TODO : 国际化
                  '搜索',
                  style: TextStyle(
                    fontWeight: theme.font.bodyLarge.fontWeight,
                    fontSize: theme.font.bodyLarge.fontSize,
                    color: (theme.color.isDark
                        ? theme.color.neutralColor4
                        : theme.color.neutralColor6),
                  ),
                ),
              ],
            ),
          );

          content = InkWell(
            onTap: () {
              isSearch.value = true;
              widget.onSearch?.call(true);
              focusNode.requestFocus();
            },
            child: content,
          );
        }

        return content;
      },
    );

    return content;
  }

  @override
  bool get wantKeepAlive => true;
}

class ChatRoomUIKitMemberListTitle extends StatefulWidget {
  const ChatRoomUIKitMemberListTitle({
    required this.profile,
    this.onMoreAction,
    super.key,
  });

  final ChatUIKitProfile profile;
  final VoidCallback? onMoreAction;

  @override
  State<ChatRoomUIKitMemberListTitle> createState() =>
      _ChatRoomUIKitMemberListTitleState();
}

class _ChatRoomUIKitMemberListTitleState
    extends State<ChatRoomUIKitMemberListTitle> with ChatUIKitThemeMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget themeBuilder(BuildContext context, ChatUIKitTheme theme) {
    Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        () {
          if (widget.profile.identify?.isNotEmpty == true &&
              ChatRoomUIKitSettings.enableParticipantItemIdentify) {
            return Container(
              margin: const EdgeInsets.only(right: 14.7),
              width: 21.67,
              height: 21.76,
              child: ChatRoomImageLoader.networkImage(
                image: widget.profile.identify,
                placeholderWidget:
                    (ChatRoomUIKitSettings.defaultIdentify == null)
                        ? Container()
                        : Image.asset(ChatRoomUIKitSettings.defaultIdentify!),
              ),
            );
          } else {
            return Container();
          }
        }(),
        ChatRoomUIKitAvatar(
          width: 40,
          height: 40,
          user: widget.profile,
        ),
        Container(
          margin: const EdgeInsets.only(left: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.profile.nickname,
                style: TextStyle(
                  fontWeight: theme.font.titleMedium.fontWeight,
                  fontSize: theme.font.titleMedium.fontSize,
                  color: (theme.color.isDark
                      ? theme.color.neutralColor98
                      : theme.color.neutralColor1),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: Container()),
        if (widget.onMoreAction != null)
          () {
            return InkWell(
              onTap: () {
                widget.onMoreAction?.call();
              },
              child: Icon(
                Icons.more_vert,
                color: (theme.color.isDark
                    ? theme.color.neutralColor98
                    : theme.color.neutralColor6),
              ),
            );
          }()
      ],
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
      height: 60,
      color: (theme.color.isDark
          ? theme.color.neutralColor1
          : theme.color.neutralColor98),
      child: content,
    );
  }
}
