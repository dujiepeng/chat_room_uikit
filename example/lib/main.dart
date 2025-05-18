import 'package:chatroom_uikit/chatroom_uikit.dart';
import 'package:chatroom_uikit_example/rooms_list_page.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ChatRoomUIKit.instance
      .init(
    options: Options.withAppKey(
      'easemob#chatroom-uikit',
      autoLogin: false,
    ),
  )
      .then((_) {
    return runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(child: Builder(builder: (ctx) {
          return TextButton(
            onPressed: () async {
              if (await ChatRoomUIKit.instance.isLoginBefore()) {
                if (context.mounted) {
                  Navigator.of(ctx).push(MaterialPageRoute(
                    builder: (ctx2) => const RoomsListView(),
                  ));
                }
              } else {
                ChatRoomUIKit.instance
                    .loginWithPassword(userId: 'du001', password: '1')
                    .then((value) {
                  if (context.mounted) {
                    Navigator.of(ctx).push(MaterialPageRoute(
                      builder: (ctx2) => const RoomsListView(),
                    ));
                  }
                }).catchError((error) {
                  debugPrint(error.toString());
                });
              }
            },
            child: const Text('Login'),
          );
        })),
      ),
    );
  }
}
