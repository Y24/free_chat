import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:free_chat/entity/enums.dart';
import 'package:free_chat/entity/history_entity.dart';
import 'package:free_chat/entity/message_entity.dart';
import 'package:free_chat/services/chat_service.dart';
import 'package:free_chat/util/function_pool.dart';

class ChatPage extends StatefulWidget {
  final int userId;
  final int toId;
  ChatPage({@required this.userId, @required this.toId});
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

class ChatPageState extends State<ChatPage> {
  int maxLines = 1;
  final menus = [
    Icons.text_fields,
    Icons.photo,
    Icons.photo_camera,
    Icons.tag_faces,
    Icons.keyboard_voice,
    Icons.attach_file,
  ];
  List<HistoryEntity> list = List.generate(
    20,
    (i) => HistoryEntity(
      content:
          'Yue,hhhhhhhh,Yue,hhhhhhhh,Yue,hhhhhhhh,Yue,hhhhhhhh,Yue,hhhhhhhh,Yue,hhhhhhhh,Yue,hhhhhhhh,Yue,hhhhhhhh,Yue,hhhhhhhh,Yue,hhhhhhhh,Yue,hhhhhhhh,Yue,hhhhhhhh,Yue,hhhhhhhh,Yue,hhhhhhhh,',
      isOthers: i % 2 == 0,
      timestamp: DateTime.now(),
    ),
  );
  TextEditingController _messageController;
  ScrollController _historyScrollController;
  ChatService chatService;
  bool isConnected = false;
  bool error = false;
  int messageId = 0;
  Map<int, HistoryEntity> proccessingMessages = Map();
  List<HistoryEntity> unreadList = [];
  List<HistoryEntity> totalList = [];
  StreamSubscription networkSubscription;
  StreamSubscription messageSubscription;
  sendMessage({String content, DateTime timestamp}) {
    if (isConnected) {
      var message = HistoryEntity(
        content: content,
        timestamp: timestamp,
        isOthers: false,
        status: MessageSendStatus.processing,
      );
      proccessingMessages[messageId] = message;
      chatService.newSend(
        id: messageId++,
        content: content,
        timestamp: timestamp,
      );
      addToHistory(message);
    }
  }

  addToHistory(HistoryEntity historyEntity) {
    if (_historyScrollController.offset == 0.0) {
      setState(() {
        list.insert(0, historyEntity);
      });
    } else {
      setState(() {
        _historyScrollController.jumpTo(0);
      });
      Future.delayed(Duration(milliseconds: 300), () {
        setState(() {
          list.insert(0, historyEntity);
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _historyScrollController = ScrollController()
      ..addListener(() {
        if (unreadList.isNotEmpty && _historyScrollController.offset == 0.0) {
          setState(() {
            list.insertAll(0, unreadList.toList());
            unreadList.clear();
          });
        }
      });
    chatService = ChatService(
        userId: widget.userId, isGroupChat: false, targetId: widget.toId)
      ..initWebSocket().then((result) {
        if (result) {
          messageSubscription = chatService.stream.listen((protocolEntity) {
            final head = protocolEntity.head;
            final body = protocolEntity.body;
            switch (head.code) {
              case ChatProtocolCode.accept:
                if (proccessingMessages.keys.contains(head.id)) {
                  setState(() {
                    proccessingMessages.remove(head.id).status =
                        MessageSendStatus.success;
                  });
                }
                break;
              case ChatProtocolCode.reject:
                if (proccessingMessages.keys.contains(head.id)) {
                  setState(() {
                    proccessingMessages.remove(head.id).status =
                        MessageSendStatus.failture;
                  });
                }
                break;
              case ChatProtocolCode.reSend:
              case ChatProtocolCode.newSend:
                break;
            }
          });
          setState(() {
            isConnected = true;
            error = false;
          });
        } else {
          setState(() {
            isConnected = false;
            error = true;
          });
        }
      });
    networkSubscription = Connectivity().onConnectivityChanged.listen((status) {
      print('New status: $status');
      if (isConnected) chatService.close();
      isConnected = false;
      if (status != ConnectivityResult.none) tryToConnect();
    });
  }

  Future<bool> tryToConnect() async {
    final reslut = await chatService.initWebSocket();
    if (reslut)
      setState(() {
        isConnected = true;
        error = false;
      });
    else {
      setState(() {
        isConnected = false;
        error = true;
      });
    }
    return reslut;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _historyScrollController.dispose();
    chatService.close();
    networkSubscription.cancel();
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
                Text(widget.userId.toString(),
                    style: TextStyle(color: Colors.white)),
                Text('Online',
                    style: TextStyle(
                        fontSize: 14, color: Colors.lightGreenAccent)),
              ],
            ),
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
            onPressed: () {},
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
    totalList.clear();
    totalList.insertAll(0, unreadList);
    totalList.insertAll(0, list);
    return Expanded(
      flex: 4,
      child: Container(
        child:
            /* StreamBuilder(
            stream: isConnected ? chatService.webSocket : Stream.empty(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (_historyScrollController.offset == 0.0) {
                  list.insert(
                      0, HistoryEntity.fromJson(json.decode(snapshot.data)));
                } else {
                  unreadList.insert(
                      0, HistoryEntity.fromJson(json.decode(snapshot.data)));
                }
              }

              return */
            ListView.separated(
          controller: _historyScrollController,
          reverse: true,
          itemCount: totalList.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == totalList.length)
              return Padding(
                padding: const EdgeInsets.all(18.0),
                child: Center(
                  child: Text(list[index - unreadList.length - 1]
                      .timestamp
                      .toString()
                      .substring(0, 16)),
                ),
              );
            return totalList[index].isOthers
                ? OthersHistoryItem(
                    content: totalList[index].content,
                    timestamp: totalList[index].timestamp,
                  )
                : OneselfHistoryItem(
                    content: totalList[index].content,
                    initTimestamp: totalList[index].timestamp,
                    status: totalList[index].status,
                  );
          },
          separatorBuilder: (BuildContext context, int index) {
            if (FunctionPool.shouldShowTimeStamp(totalList, index))
              return Padding(
                padding: const EdgeInsets.all(18.0),
                child: Center(
                  child: Text(
                      totalList[index].timestamp.toString().substring(0, 16)),
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
          if (unreadList.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: Material(
                shape: CircleBorder(),
                elevation: 8,
                child: GestureDetector(
                  child: Text(unreadList.length.toString()),
                  onTap: () {
                    print('Hi!');
                    //list.insertAll(0, unreadList.toList());
                    //unreadList.clear();
                    setState(() {
                      _historyScrollController.jumpTo(0.0);
                    });
                  },
                ),
              ),
            ),
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
                          controller: _messageController,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.send,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          // print(_historyScrollController.offset);
                          sendMessage(
                            content: _messageController.text +
                                DateTime.now().toString(),
                            timestamp: DateTime.now(),
                          );
                          _messageController.clear();
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
    if (error)
      return Text(
        'Connection error',
        style: TextStyle(color: Colors.red),
      );
    if (isConnected)
      return Text(
        'Connection success',
        style: TextStyle(color: Colors.green),
      );
    return Text(
      'Connecting ...',
      style: TextStyle(color: Colors.white),
    );
  }
}
