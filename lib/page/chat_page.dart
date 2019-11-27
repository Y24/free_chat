import 'package:flutter/material.dart';
import 'package:free_chat/controller/chat_page_controller.dart';
import 'package:free_chat/controller/entity/exposed_state.dart';
import 'package:free_chat/provider/entity/history_entity.dart';
import 'package:free_chat/util/function_pool.dart';

class ChatPage extends StatefulWidget {
  final String from;
  final String to;
  ChatPage({@required this.from, @required this.to});
  @override
  ChatPageState createState() => ChatPageState();
  static ChatPageState of(BuildContext context, {bool nullOk = false}) {
    assert(nullOk != null);
    assert(context != null);
    final ChatPageState result =
        context.ancestorStateOfType(const TypeMatcher<ChatPageState>());
    if (nullOk || result != null) return result;
    throw FlutterError('Love you, yue');
  }
}

class ChatPageState extends ExposedState<ChatPage> {
  final String from;
  final String to;
  ChatPageState({this.from, this.to});
  final menus = [
    Icons.text_fields,
    Icons.photo,
    Icons.photo_camera,
    Icons.tag_faces,
    Icons.keyboard_voice,
    Icons.attach_file,
  ];
  ChatPageController pageController = ChatPageController();
  @override
  void initState() {
    super.initState();
    pageController.init(state: this);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(widget.from.toString(),
                    style: TextStyle(color: Colors.white)),
                Text(
                    !pageController.error && pageController.isConnected
                        ? 'Online'
                        : 'Offline',
                    style: TextStyle(
                        fontSize: 14,
                        color:
                            !pageController.error && pageController.isConnected
                                ? Colors.lightGreenAccent[100]
                                : Colors.grey)),
              ],
            ),
            SizedBox(width: 12),
            buildWebSocketIndicator(),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.videocam,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.phone_forwarded,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
            onPressed: () {
              pageController.settingButtonOnPressed(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          buildMessageHistoryWidget(),
          buildBottumMessageSendWidget(),
        ],
      ),
    );
  }

  Expanded buildMessageHistoryWidget() {
    pageController.messageHistoryPreWork();
    pageController.setClearHistoryTimer();
    if (pageController.totalList.length == 0)
      return Expanded(
        child: Container(
          child: ListView(
            controller: pageController.historyScrollController,
            reverse: true,
          ),
        ),
      );
    return Expanded(
      flex: 4,
      child: Container(
        padding: EdgeInsets.only(bottom: 14),
        child: ListView.separated(
          controller: pageController.historyScrollController,
          reverse: true,
          itemCount: pageController.totalList.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == pageController.totalList.length)
              return Padding(
                padding: const EdgeInsets.all(18.0),
                child: Center(
                  child: Text(pageController
                      .list[index - pageController.unreadList.length - 1]
                      .timestamp
                      .toString()
                      .substring(0, 16)),
                ),
              );
            return pageController.totalList[index].isOthers
                ? OthersHistoryItem(
                    content: pageController.totalList[index].content,
                    timestamp: pageController.totalList[index].timestamp,
                  )
                : (OneselfHistoryItem(
                    content: pageController.totalList[index].content,
                    initTimestamp: pageController.totalList[index].timestamp,
                    status: pageController.totalList[index].status,
                  ));
          },
          separatorBuilder: (BuildContext context, int index) {
            if (FunctionPool.shouldShowTimeStamp(
                pageController.totalList.cast<HistoryEntity>(), index))
              return Padding(
                padding: const EdgeInsets.all(18.0),
                child: Center(
                  child: Text(pageController.totalList[index].timestamp
                      .toString()
                      .substring(0, 16)),
                ),
              );
            return Divider(
              color: Colors.white,
            );
          },
        ),
      ),
    );
  }

  Align buildBottumMessageSendWidget() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Column(
        children: <Widget>[
          Material(
            elevation: 14,
            child: Container(
              height: 114,
              padding: EdgeInsets.only(left: 14, right: 14, top: 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          style: TextStyle(fontSize: 18),
                          decoration: null,
                          maxLines: 2,
                          controller: pageController.messageController,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.send,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          if (pageController.messageController.text != '')
                            pageController.sendMessage(
                              content: pageController.messageController.text,
                              timestamp: DateTime.now(),
                            );
                          pageController.messageController.clear();
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: menus
                        .map(
                          (icondata) => Expanded(
                            child: IconButton(
                              icon: Icon(
                                icondata,
                                color: Colors.blue,
                              ),
                              onPressed: () {},
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildWebSocketIndicator() {
    if (pageController.error)
      return Icon(
        Icons.error,
        color: Colors.red,
      );
    if (pageController.isConnected)
      return Icon(
        Icons.check_circle,
        color: Colors.lightGreenAccent[200],
      );
    return Text(
      '...',
      style: TextStyle(color: Colors.white),
    );
  }

  @override
  void update(fn) {
    setState(fn);
  }
}
