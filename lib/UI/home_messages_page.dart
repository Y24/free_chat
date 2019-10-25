import 'package:flutter/material.dart';

class HomeMessagesPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String username;
  HomeMessagesPage({this.scaffoldKey, this.username});
  @override
  _HomeMessagesPageState createState() => _HomeMessagesPageState();
}

class _HomeMessagesPageState extends State<HomeMessagesPage> {
  List list = new List();
  int x = 0;
  Future<Null> _onRefresh() async {
    x++;
    await Future.delayed(Duration(seconds: 1), () {
      print('refresh');
      setState(() {
        list = List.generate(20, (i) => '第 $x 次刷新后数据 $i');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(this.list[index]),
          );
        },
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
