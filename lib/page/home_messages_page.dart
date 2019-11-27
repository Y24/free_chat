import 'package:flutter/material.dart';
import 'package:free_chat/page/chat_page.dart';
import 'package:free_chat/provider/base_provider.dart';
import 'package:free_chat/provider/conversation_provider.dart';
import 'package:free_chat/provider/entity/provider_code.dart';
import 'package:free_chat/provider/entity/provider_entity.dart';
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
  bool fetched = false;
  IProvider provider;
  List list = [];

  Future<Null> _onRefresh() async {
    if (fetched) {
      try {
        provider.setEntity(ProviderEntity(
            code: ConversationProviderCode.queryAllConversation));
        list = await provider.provide();
        setState(() {
          list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        });
      } catch (e) {
        await initProvider();
      }
    }
  }

  @override
  void dispose() {
    fetched = false;
    provider?.close();
    super.dispose();
    print('messages dispose');
  }

  Future initProvider() async {
    fetched = false;
    provider = ConversationProvider(username: widget.username);
    final result = await provider.init();
    print('provider init result: $result');
    if (result) {
      provider.setEntity(
          ProviderEntity(code: ConversationProviderCode.queryAllConversation));
      list = await provider.provide();
      fetched = true;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    initProvider();
  }

  enterConversation(BuildContext context, {final String username}) {
    print('enter chat page from: ${widget.username} to: $username');
    Navigator.of(context).push(ScaleRoute(
        page: ChatPage(
      from: widget.username,
      to: username,
    )));
  }

  deleteConversation(int index) {
    var deleted = list.removeAt(index);
    provider.setEntity(ProviderEntity(
      code: ConversationProviderCode.deleteConversation,
      content: deleted,
    ));
    provider.provide();
    setState(() {});
  }

  starConversation(int index) {
    setState(() {
      list.insert(0, list.removeAt(index));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!fetched)
      return Center(
        child: CircularProgressIndicator(),
      );
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
      semanticsLabel: 'messages',
      semanticsValue: 'push_to_refresh',
    );
  }
}
