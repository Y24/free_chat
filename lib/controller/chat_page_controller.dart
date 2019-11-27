import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:free_chat/controller/base_page_controller.dart';
import 'package:free_chat/controller/entity/exposed_state.dart';
import 'package:free_chat/entity/backend/handle_result_entity.dart';
import 'package:free_chat/entity/enums.dart';
import 'package:free_chat/page/chat_setting_page.dart';
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
import 'package:free_chat/util/ui/page_tansitions/fade_route.dart';

class ChatPageController extends BasePageController {
  final String from;
  final String to;
  int maxLines = 1;
  bool fetched0 = false;
  IProvider provider0;
  bool fetched1 = false;
  IProvider provider1;
  List list = [];
  TextEditingController messageController;
  ScrollController historyScrollController;
  bool isConnecting = false;
  bool isConnected = false;
  bool error = false;
  int messageId = 0;
  int setting = 0;
  IProtocolService chatService;
  Map<String, HandleResultEntity> handleResultPool = {};
  List<HistoryEntity> newRecieveHistoryPool = [];
  List<ProviderEntity> acceptHistoryPool = [];
  Map<String, dynamic> proccessingMessages = {};
  List<HistoryEntity> unreadList = [];
  List totalList = [];
  StreamSubscription networkSubscription;
  StreamSubscription messageSubscription;
  Timer hideSendDoneTimer;
  Timer clearHistoryTimer;
  Timer syncHistoryTimer;
  @override
  String get path => r'lib/page/chat_page.dart';
  ChatPageController({this.from, this.to});
  @override
  init({ExposedState state}) {
    super.init(state: state);
    initProvider();
    syncHistoryTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      syncNewRecieveHistory();
      syncAccpetHistory();
    });
    messageController = TextEditingController();
    historyScrollController = ScrollController()
      ..addListener(() {
        if (unreadList.isNotEmpty && historyScrollController.offset == 0.0) {
          state.update(() {
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
      state.update(() {
        isConnected = true;
        error = false;
      });
    else {
      state.update(() {
        isConnected = false;
        error = true;
      });
    }
    return reslut;
  }

  @override
  void dispose() {
    hideSendDoneTimer?.cancel();
    clearHistoryTimer?.cancel();
    syncHistoryTimer?.cancel();
    provider0?.close();
    provider1?.close();
    chatService?.dispose();
    messageController?.dispose();
    historyScrollController?.dispose();
    networkSubscription?.cancel();
    messageSubscription?.cancel();
    hideSendDoneTimer = clearHistoryTimer = syncHistoryTimer = null;
    provider0 = provider1 = null;
    chatService = null;
    messageController = historyScrollController = null;
    networkSubscription = messageSubscription = null;
  }

  sendMessage({String content, DateTime timestamp}) {
    if (isConnected) {
      var message = HistoryEntity(
        historyId: messageId,
        username: to,
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
            from: from,
            to: to,
            groupChatFlag: false,
            password: '',
          ),
          body: ChatBodyEntity(content: content));
      chatService.setEntity(protocolEntity);
      if (!chatService.send()) {
        print('send fails');
        initWebSocket();
        state.update(() {
          message.status = MessageSendStatus.failture;
        });
      }
      Timer.periodic(Duration(seconds: 5), (timer) async {
        if (message.status == MessageSendStatus.processing) {
          message.status = MessageSendStatus.failture;
          provider0.setEntity(ProviderEntity(
              code: HistoryProviderCode.updateHistory, content: message));
          await provider0.provide();
          state.update(() {});
        }
        timer?.cancel();
      });
      addToHistory(message);
    }
  }

  void settingButtonOnPressed(BuildContext context) {
    Navigator.of(context).push(FadeRoute(page: ChatSettingPage())).then((re) {
      initProvider();
      messageController = TextEditingController();
      historyScrollController = ScrollController()
        ..addListener(() {
          if (unreadList.isNotEmpty && historyScrollController.offset == 0.0) {
            state.update(() {
              list.insertAll(0, unreadList);
              list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
              unreadList.clear();
            });
          }
        });
      initWebSocket();
      networkSubscription =
          Connectivity().onConnectivityChanged.listen((status) {
        print('New status: $status');
        if (isConnected) chatService.dispose();
        isConnected = false;
        if (status != ConnectivityResult.none && !isConnecting) tryToConnect();
      });
      Timer.periodic(Duration(milliseconds: 600), (timer) {
        timer.cancel();
        print('re: $re');
        state.update(() {
          setting = re ?? 0;
        });
      });
    });
  }

  void messageHistoryPreWork() {
    totalList.clear();
    totalList.insertAll(0, unreadList);
    totalList.insertAll(0, list);
    clearHistoryTimer?.cancel();
    clearHistoryTimer = null;
  }

  void setClearHistoryTimer() {
    if (setting != 0) {
      clearHistoryTimer =
          Timer.periodic(Duration(seconds: setting), (timer) async {
        provider0
            .setEntity(ProviderEntity(code: HistoryProviderCode.deleteHistory));
        await provider0.provide();
        state.update(() {
          clearHistory();
        });
      });
    }
  }

  void clearHistory() {
    final now = DateTime.now();
    list.removeWhere((history) =>
        (history as HistoryEntity).timestamp.difference(now).abs().inSeconds >
        setting);
    unreadList.removeWhere((history) =>
        history.timestamp.difference(now).abs().inSeconds > setting);
  }

  addToHistory(HistoryEntity historyEntity) async {
    provider1.setEntity(ProviderEntity(
        code: ConversationProviderCode.queryConversation,
        content: ConversationEntity(username: to)));
    final result = await provider1.provide();
    print('add to history conversation hook result: $result');
    if (result == ConversationEntity.emptyConversationEntity) {
      provider1.setEntity(ProviderEntity(
          code: ConversationProviderCode.addConversation,
          content: ConversationEntity(
            username: to,
            alias: 'free chat',
            overview: historyEntity.content.length > 8
                ? historyEntity.content.substring(0, 6) + '..'
                : historyEntity.content,
            timestamp: DateTime.now(),
          )));
      await provider1.provide();
    } else {
      result.timestamp = DateTime.now();
      result.overview = historyEntity.content.length > 8
          ? historyEntity.content.substring(0, 6) + '..'
          : historyEntity.content;
      provider1.setEntity(ProviderEntity(
          code: ConversationProviderCode.updateConversation, content: result));
      await provider1.provide();
    }
    if (historyScrollController.offset == 0.0) {
      provider0.setEntity(ProviderEntity(
          code: HistoryProviderCode.addHistory, content: historyEntity));
      await provider0.provide();
      state.update(() {
        list.insert(0, historyEntity);
      });
    } else {
      state.update(() {
        historyScrollController.jumpTo(0);
      });
      provider0.setEntity(ProviderEntity(
          code: HistoryProviderCode.addHistory, content: historyEntity));
      await provider0.provide();
      Future.delayed(Duration(milliseconds: 300), () {
        state.update(() {
          list.insert(0, historyEntity);
        });
      });
    }
  }

  void initProvider() {
    fetched0 = false;
    provider0 = HistoryProvider(username: from)
      ..init().then((result) async {
        print('provider0 init result: $result');
        if (result) {
          provider0.setEntity(ProviderEntity(
              code: HistoryProviderCode.queryAllHistory,
              content: AccountEntity(
                username: to,
              )));
          list = await provider0.provide();
          list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          state.update(() {
            fetched0 = true;
          });
        }
      });
    provider1 = ConversationProvider(username: from)
      ..init().then((result) async {
        print('provider1 init result: $result');
        if (result) {
          fetched1 = true;
        }
      });
  }

  void initWebSocket() async {
    isConnected = false;
    isConnecting = true;
    chatService = ChatProtocolService(
      protocolHandler: ChatProtocolHandler(
        id: from,
        password: '',
        from: from,
        to: to,
        groupChatFlag: false,
      ),
      protocolSender: ChatProtocolSender(
        username: from,
        password: '',
        from: from,
        to: to,
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
          chatService.setEntity(ChatProtocolEntity.fromJson(json.decode(data)));
          final handleResult = chatService.handle(ws);
          print('handle result pool: $handleResultPool');
          print('now data:$data');
          print('handle result content: ${handleResult.content}');
          switch (handleResult.code) {
            case ChatProtocolCode.accept:
              //well, null means failture.
              if (handleResult.content != null) {
                provider0.setEntity(ProviderEntity(
                    code: HistoryProviderCode.updateHistory,
                    content: HistoryEntity(
                      timestamp: handleResult.content,
                      username: to,
                      status: MessageSendStatus.success,
                    )));
                await provider0.provide();
                print('handleResult.content: ${handleResult.content}');
                print('processing messages: ${proccessingMessages.toString()}');
                state.update(() {
                  proccessingMessages[handleResult.content.toString()].status =
                      MessageSendStatus.success;
                });
                hideSendDoneTimer?.cancel();
                hideSendDoneTimer =
                    Timer.periodic(Duration(seconds: 4), (timer) {
                  timer.cancel();
                  state.update(() {
                    proccessingMessages[handleResult.content.toString()]
                        .status = MessageSendStatus.done;
                  });
                });
              } else {
                acceptHistoryPool.add(ProviderEntity(
                    code: HistoryProviderCode.updateHistory,
                    content: HistoryEntity(
                      timestamp: handleResult.content,
                      username: to,
                      status: MessageSendStatus.failture,
                    )));
                state.update(() {
                  proccessingMessages[handleResult.content.toString()].status =
                      MessageSendStatus.failture;
                });
              }
              break;
            case ChatProtocolCode.newSend:
              print('recieve new send:${handleResult.content}');
              newRecieveHistoryPool.add(handleResult.content['entity']);
              if (historyScrollController.offset == 0.0) {
                state.update(() {
                  list.insert(0, handleResult.content['entity']);
                });
              } else {
                state.update(() {
                  unreadList.insert(0, handleResult.content['entity']);
                });
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
      state.update(() {
        isConnected = true;
        error = false;
      });
    } else {
      state.update(() {
        isConnected = false;
        error = true;
      });
    }
  }

  void syncAccpetHistory() {
    Future.doWhile(() async {
      if (acceptHistoryPool.isEmpty) return false;
      var entity = acceptHistoryPool.removeAt(0);
      provider0.setEntity(entity);
      return await provider0.provide();
    });
  }

  void syncNewRecieveHistory() {
    //  print('call to sync new recieve: $newRecieveHistoryPool');
    Future.doWhile(() async {
      if (newRecieveHistoryPool.isEmpty) return false;
      var entity = newRecieveHistoryPool.removeAt(0);
      provider0.setEntity(ProviderEntity(
          code: HistoryProviderCode.queryHistoryByTimestamp, content: entity));
      if (await provider0.provide() != HistoryEntity.emptyHistoryEntity)
        return true;
      provider0.setEntity(ProviderEntity(
          code: HistoryProviderCode.addHistory, content: entity));
      return await provider0.provide();
    });
  }
}
