import 'package:flutter/material.dart';
import 'package:free_chat/entity/message_entity.dart';

class HomeMessagesPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String username;
  HomeMessagesPage({this.scaffoldKey, this.username});
  @override
  _HomeMessagesPageState createState() => _HomeMessagesPageState();
}

class _HomeMessagesPageState extends State<HomeMessagesPage> {
  List<MessageEntity> list = List.generate(
    20,
    (i) => MessageEntity(alias: 'Yue', subTitle: 'Love', trailing: '5:20 PM'),
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
              alias: '$x Yue', subTitle: 'Love', trailing: '5:20 PM'),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) =>
            list[index].toSlideItem(context),
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
