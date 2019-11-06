import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:free_chat/entity/enums.dart';
import 'package:free_chat/protocol/entity/chat_protocol_entity.dart';
import 'package:free_chat/protocol/handler/chat_protocol_handler.dart';
import 'package:free_chat/protocol/sender/chat_protocol_sender.dart';
import 'package:free_chat/protocol/service/base_protocol_service.dart';
import 'package:free_chat/protocol/service/chat_protocol_service.dart';
import 'package:free_chat/provider/base_provider.dart';
import 'package:free_chat/provider/conversation_provider.dart';
import 'package:free_chat/provider/entity/account_entity.dart';
import 'package:free_chat/provider/entity/conversation_entity.dart';
import 'package:free_chat/provider/entity/history_entity.dart';
import 'package:free_chat/provider/entity/provider_code.dart';
import 'package:free_chat/provider/entity/provider_entity.dart';
import 'package:free_chat/provider/history_provider.dart';
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
  bool fetched0 = false;
  IProvider provider0;
  bool fetched1 = false;
  IProvider provider1;
  List list = [];
  TextEditingController _messageController;
  ScrollController _historyScrollController;
  bool isConnecting = false;
  bool isConnected = false;
  bool error = false;
  int messageId = 0;
  IProtocolService chatService;
  Map<String, dynamic> proccessingMessages = {};
  List<HistoryEntity> unreadList = [];
  List totalList = [];
  StreamSubscription networkSubscription;
  StreamSubscription messageSubscription;
  Timer _hideSendDoneTimer;
  sendMessage({String content, DateTime timestamp}) {
    if (isConnected) {
      var message = HistoryEntity(
        historyId: messageId,
        username: widget.to,
        content: content,
        isOthers: false,
        timestamp: timestamp,
        status: MessageSendStatus.processing,
      );
      proccessingMessages[message.timestamp.toString()] = message;

      print('try new send: content:$content');
      ChatProtocolEntity protocolEntity = ChatProtocolEntity(
          head: ChatHeadEntity(
            id: messageId++,
            code: ChatProtocolCode.newSend,
            timestamp: timestamp,
            from: widget.from,
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
      Timer.periodic(Duration(seconds: 5), (timer) async {
        if (message.status == MessageSendStatus.processing) {
          message.status = MessageSendStatus.failture;
          provider0.setEntity(ProviderEntity(
              code: HistoryProviderCode.updateHistory, content: message));
          await provider0.provide();
          setState(() {});
        }
        timer?.cancel();
      });
      addToHistory(message);
    }
  }

  addToHistory(HistoryEntity historyEntity) async {
    provider1.setEntity(ProviderEntity(
        code: ConversationProviderCode.queryConversation,
        content: ConversationEntity(username: widget.to)));
    final result = await provider1.provide();
    print('add to history conversation hook result: $result');
    if (result == ConversationEntity.emptyConversationEntity) {
      provider1.setEntity(ProviderEntity(
          code: ConversationProviderCode.addConversation,
          content: ConversationEntity(
            username: widget.to,
            alias: 'free chat',
            overview: historyEntity.content.length > 8
                ? historyEntity.content.substring(0, 6) + '..'
                : historyEntity.content,
            timestamp: DateTime.now(),
          )));
      provider1.provide();
    } else {
      result.timestamp = DateTime.now();
      result.overview = historyEntity.content.length > 8
          ? historyEntity.content.substring(0, 6) + '..'
          : historyEntity.content;
      provider1.setEntity(ProviderEntity(
          code: ConversationProviderCode.updateConversation, content: result));
      provider1.provide();
    }
    if (_historyScrollController.offset == 0.0) {
      provider0.setEntity(ProviderEntity(
          code: HistoryProviderCode.addHistory, content: historyEntity));
      await provider0.provide();
      setState(() {
        list.insert(0, historyEntity);
      });
    } else {
      setState(() {
        _historyScrollController.jumpTo(0);
      });
      provider0.setEntity(ProviderEntity(
          code: HistoryProviderCode.addHistory, content: historyEntity));
      await provider0.provide();
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
        id: widget.from,
        password: '',
        from: widget.from,
        to: widget.to,
        groupChatFlag: false,
      ),
      protocolSender: ChatProtocolSender(
        username: widget.from,
        password: '',
        from: widget.from,
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
              //well, null means failture.
              if (handleResult.content != null) {
                provider0.setEntity(ProviderEntity(
                    code: HistoryProviderCode.updateHistory,
                    content: HistoryEntity(
                      timestamp: handleResult.content,
                      username: widget.to,
                      status: MessageSendStatus.success,
                    )));
                await provider0.provide();
                print('handleResult.content: ${handleResult.content}');
                print('processing messages: ${proccessingMessages.toString()}');
                setState(() {
                  proccessingMessages[handleResult.content.toString()].status =
                      MessageSendStatus.success;
                });
                _hideSendDoneTimer =
                    Timer.periodic(Duration(seconds: 4), (timer) {
                  timer.cancel();
                  setState(() {
                    proccessingMessages[handleResult.content.toString()]
                        .status = MessageSendStatus.done;
                  });
                });
              } else {
                provider0.setEntity(ProviderEntity(
                    code: HistoryProviderCode.updateHistory,
                    content: HistoryEntity(
                      timestamp: handleResult.content,
                      username: widget.to,
                      status: MessageSendStatus.failture,
                    )));
                await provider0.provide();
                setState(() {
                  proccessingMessages[handleResult.content.toString()].status =
                      MessageSendStatus.failture;
                });
              }
              break;
            case ChatProtocolCode.newSend:
              print('recieve new send:${handleResult.content}');
              switch (handleResult.content['status']) {
                case SendStatus.success:
                  provider0.setEntity(ProviderEntity(
                      code: HistoryProviderCode.addHistory,
                      content: handleResult.content['entity']));
                  await provider0.provide();
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
    fetched0 = false;
    provider0 = HistoryProvider(username: widget.from)
      ..init().then((result) async {
        print('provider0 init result: $result');
        if (result) {
          provider0.setEntity(ProviderEntity(
              code: HistoryProviderCode.queryAllHistory,
              content: AccountEntity(
                username: widget.to,
              )));
          list = await provider0.provide();
          list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          setState(() {
            fetched0 = true;
          });
        }
      });
    provider1 = ConversationProvider(username: widget.from)
      ..init().then((result) async {
        print('provider1 init result: $result');
        if (result) {
          fetched1 = true;
        }
      });
    _messageController = TextEditingController();
    _historyScrollController = ScrollController()
      ..addListener(() {
        if (unreadList.isNotEmpty && _historyScrollController.offset == 0.0) {
          setState(() {
            list.insertAll(0, unreadList);
            list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
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
    _hideSendDoneTimer?.cancel();
    provider0?.close();
    provider1?.close();
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
                Text(widget.from.toString(),
                    style: TextStyle(color: Colors.white)),
                Text(!error && isConnected ? 'Online' : 'Offline',
                    style: TextStyle(
                        fontSize: 14,
                        color: !error && isConnected
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
    if (totalList.length == 0)
      return Expanded(
        child: Container(),
      );
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
                : (OneselfHistoryItem(
                    content: totalList[index].content,
                    initTimestamp: totalList[index].timestamp,
                    status: totalList[index].status,
                  ));
          },
          separatorBuilder: (BuildContext context, int index) {
            if (FunctionPool.shouldShowTimeStamp(
                totalList.cast<HistoryEntity>(), index))
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
        Icons.check_circle,
        color: Colors.lightGreenAccent[200],
      );
    return Text(
      '...',
      style: TextStyle(color: Colors.white),
    );
  }
}
