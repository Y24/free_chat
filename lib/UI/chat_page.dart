import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:free_chat/entity/enums.dart';
import 'package:free_chat/entity/history_entity.dart';
import 'package:free_chat/protocol/entity/chat_protocol_entity.dart';
import 'package:free_chat/protocol/handler/chat_protocol_handler.dart';
import 'package:free_chat/protocol/sender/chat_protocol_sender.dart';
import 'package:free_chat/protocol/service/base_protocol_service.dart';
import 'package:free_chat/protocol/service/chat_protocol_service.dart';
import 'package:free_chat/util/function_pool.dart';

class ChatPage extends StatefulWidget {
  final String id;
  final String to;
  ChatPage({@required this.id, @required this.to});
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
  bool isConnecting = false;
  bool isConnected = false;
  bool error = false;
  int messageId = 0;
  IProtocolService chatService;
  Map<int, HistoryEntity> proccessingMessages = {};
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
      print('try new send: content:$content');
      ChatProtocolEntity protocolEntity = ChatProtocolEntity(
          head: ChatHeadEntity(
            id: messageId++,
            code: ChatProtocolCode.newSend,
            timestamp: timestamp,
            from: widget.id,
            to: widget.to,
            groupChatFlag: false,
            password: '',
          ),
          body: ChatBodyEntity(content: content));
      chatService.setEntity(protocolEntity);
      if (!chatService.send()) {
        initWebSocket();
        setState(() {
          message.status = MessageSendStatus.failture;
        });
      }
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

  void initWebSocket() async {
    isConnected = false;
    isConnecting = true;
    chatService = ChatProtocolService(
      protocolHandler: ChatProtocolHandler(
        id: widget.id,
        password: '',
        from: widget.id,
        to: widget.to,
        groupChatFlag: false,
      ),
      protocolSender: ChatProtocolSender(
        username: widget.id,
        password: '',
        from: widget.id,
        to: widget.to,
        groupChatFlag: false,
      ),
    );
    final ws = await chatService.init();
    print('ws: $ws');
    isConnecting = false;
    //ws.add('test for ws');
    if (ws != null) {
      print('ws!=null');
      ws.listen((data) async {
        try {
          print('get data: $data');
          final request = ChatProtocolEntity.fromJson(json.decode(data));
          chatService.setEntity(request);
          final handleResult = await chatService.handle(ws);
          print(handleResult);
          switch (handleResult.code) {
            case ChatProtocolCode.accept:
              //well, gt 0 means success.
              if (handleResult.content >= 0) {
                setState(() {
                  print('handleResult.content: ${handleResult.content}');
                  print(
                      'processing messages: ${proccessingMessages.toString()}');
                  proccessingMessages[handleResult.content].status =
                      MessageSendStatus.success;
                });
                Future.delayed(Duration(seconds: 4), () {
                  setState(() {
                    proccessingMessages[handleResult.content].status = null;
                  });
                });
              } else {
                setState(() {
                  proccessingMessages[-handleResult.content].status =
                      MessageSendStatus.failture;
                });
              }
              break;
            case ChatProtocolCode.newSend:
              print('recieve new send:${handleResult.content}');
              switch (handleResult.content['status']) {
                case SendStatus.success:
                  if (_historyScrollController.offset == 0.0) {
                    setState(() {
                      list.insert(0, handleResult.content['entity']);
                    });
                  } else {
                    setState(() {
                      unreadList.insert(0, handleResult.content['entity']);
                    });
                  }
                  break;
                case SendStatus.serverError:
                  break;
                case SendStatus.reject:
                  break;
                default:
                  break;
              }
              break;
            case ChatProtocolCode.reSend:
            case ChatProtocolCode.reject:
            default:
          }

          //await handler.dispose();
        } catch (e) {
          print(e);
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
    initWebSocket();
    networkSubscription = Connectivity().onConnectivityChanged.listen((status) {
      print('New status: $status');
      if (isConnected) chatService.dispose();
      isConnected = false;
      if (status != ConnectivityResult.none && !isConnecting) tryToConnect();
    });
  }

  Future<WebSocket> tryToConnect() async {
    isConnecting = true;
    final reslut = await chatService.init();
    isConnecting = false;
    if (reslut != null)
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
    print('call dispose chat_page:233');
    chatService?.dispose();
    _messageController?.dispose();
    _historyScrollController?.dispose();
    networkSubscription?.cancel();
    messageSubscription?.cancel();
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
                Text(widget.id.toString(),
                    style: TextStyle(color: Colors.white)),
                Text(!error && isConnected ? 'Online' : 'Offline',
                    style: TextStyle(
                        fontSize: 14,
                        color: !error && isConnected
                            ? Colors.lightGreenAccent
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
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          buildMessageHistoryWidget(),
          if (unreadList.isNotEmpty)
            ClipOval(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  unreadList.length.toString(),
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
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
        padding: EdgeInsets.only(bottom: 14),
        child: ListView.separated(
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
                          if (_messageController.text != '')
                            sendMessage(
                              content: _messageController.text,
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
      return Icon(
        Icons.error,
        color: Colors.red,
      );
    if (isConnected)
      return Icon(
        Icons.check,
        color: Colors.green,
      );
    return Text(
      '...',
      style: TextStyle(color: Colors.white),
    );
  }
}
