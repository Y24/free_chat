import 'package:flutter/material.dart';
import 'package:free_chat/UI/chat_page.dart';
import 'package:free_chat/entity/message_entity.dart';
import 'package:free_chat/util/ui/page_tansitions/scale_rotation_route.dart';
import 'package:free_chat/util/ui/page_tansitions/scale_route.dart';

class HomeMessagesPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String username;
  HomeMessagesPage({this.scaffoldKey, this.username});
  @override
  HomeMessagesPageState createState() => HomeMessagesPageState();
  static HomeMessagesPageState of(BuildContext context, {bool nullOk = false}) {
    assert(nullOk != null);
    assert(context != null);
    final HomeMessagesPageState result =
        context.ancestorStateOfType(const TypeMatcher<HomeMessagesPageState>());
    if (nullOk || result != null) return result;
    throw FlutterError('Love you, yue');
  }
}

class HomeMessagesPageState extends State<HomeMessagesPage> {
  List<MessageEntity> list = List.generate(
    20,
    (i) => MessageEntity(
        username: 'yue', alias: 'Yue', overview: 'Love', timestamp: '5:20 PM'),
  );
  int x = 0;

  Future<Null> _onRefresh() async {
    x++;
    await Future.delayed(Duration(seconds: 1), () {
      print('refresh');
      setState(() {
        list = List.generate(
          20,
          (i) => MessageEntity(
              username: '1yue1',
              alias: '$x Yue',
              overview: 'Love',
              timestamp: '5:20 PM'),
        );
      });
    });
  }

  enterConversation(BuildContext context, {final String username}) {
    print('enter chat page from: ${widget.username} to: $username');
    Navigator.of(context).push(ScaleRoute(
        page: ChatPage(
      id: widget.username,
      to: username,
      // toId: toId,
    )));
  }

  deleteConversation(int index) {
    setState(() {
      list.removeAt(index);
    });
  }

  starConversation(int index) {
    setState(() {
      list.insert(0, list.removeAt(index));
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) =>
            list[index].toSlideItem(context, index),
      ),
      onRefresh: _onRefresh,
      // displacement:30,
      color: Colors.blue,
      backgroundColor: Colors.white,
      // notificationPredicate:,
      semanticsLabel: 'label',
      semanticsValue: 'push_to_refresh',
    );
  }
}
