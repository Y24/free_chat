import 'dart:convert';
import 'dart:io';

import 'package:free_chat/entity/backend/handle_result_entity.dart';
import 'package:free_chat/entity/enums.dart';
import 'package:free_chat/protocol/entity/chat_protocol_entity.dart';
import 'package:free_chat/protocol/handler/base_protocol_handler.dart';
import 'package:free_chat/provider/entity/history_entity.dart';

abstract class IChatProtocolHandler implements IProtocolHandler {
  HandleResultEntity handleNewSend();
  HandleResultEntity handleAccept();
  HandleResultEntity handleReSend();
  HandleResultEntity handleReject();
}

class ChatProtocolHandler extends BaseProtocolHandler
    implements IChatProtocolHandler {
  final id;
  final String password;
  final String from;
  final String to;
  final bool groupChatFlag;
  WebSocket _webSocket;
  ChatProtocolEntity protocolEntity;
  ChatProtocolHandler(
      {this.id, this.password, this.from, this.to, this.groupChatFlag});

  @override
  String get dbName => 'chat';
  @override
  Future<bool> init() {
    return super.setUp();
  }

  @override
  HandleResultEntity handle(WebSocket webSocket) {
    _webSocket = webSocket;
    switch (protocolEntity.head.code as ChatProtocolCode) {
      case ChatProtocolCode.newSend:
        return handleNewSend();
      case ChatProtocolCode.reSend:
        return handleReSend();
      case ChatProtocolCode.accept:
        return handleAccept();
      case ChatProtocolCode.reject:
        return handleReject();
      default:
        print('Here is a bug to be fixed');
        return null;
    }
  }

  bool _authenticate() => true;
  void _response({ChatProtocolCode code, String content, DateTime timestamp}) {
    _webSocket.add(json.encode(ChatProtocolEntity(
      head: ChatHeadEntity(
        id: id,
        code: code,
        timestamp: timestamp,
        from: from,
        to: to,
        groupChatFlag: groupChatFlag,
      ),
      body: ChatBodyEntity(content: content),
    ).toJson()));
  }

  @override
  HandleResultEntity handleNewSend(){
    print('Handle new send: ${protocolEntity.body.content}');
    HandleResultEntity resultEntity =
        HandleResultEntity(code: ChatProtocolCode.newSend);
    if (_authenticate()) {
      //TODO:
      _response(
        code: ChatProtocolCode.accept,
        content: 'Free Chat',
        timestamp: protocolEntity.head.timestamp,
      );
      resultEntity.content = {
        'status': SendStatus.success,
        'entity': HistoryEntity(
            historyId: protocolEntity.head.id,
            username: protocolEntity.head.to,
            content: protocolEntity.body.content,
            isOthers: true,
            timestamp: protocolEntity.head.timestamp,
            status: MessageSendStatus.success),
      };
      return resultEntity;
    } else {
      _response(
        code: ChatProtocolCode.reject,
        content: 'password',
        timestamp: protocolEntity.head.timestamp,
      );
      resultEntity.content = {
        'status': SendStatus.reject,
        'entity': HistoryEntity(
          historyId: protocolEntity.head.id,
          username: protocolEntity.head.to,
          content: protocolEntity.body.content,
          isOthers: true,
          timestamp: protocolEntity.head.timestamp,
          status: MessageSendStatus.failture,
        ),
      };
      return resultEntity;
    }
  }

  @override
  HandleResultEntity handleAccept() {
    HandleResultEntity resultEntity =
        HandleResultEntity(code: ChatProtocolCode.accept);
    if (_authenticate()) {
      resultEntity.content = protocolEntity.head.timestamp;
      return resultEntity;
    } else {
      resultEntity.content = null;
      return resultEntity;
    }
  }

  @override
  HandleResultEntity handleReSend(){
    HandleResultEntity resultEntity =
        HandleResultEntity(code: ChatProtocolCode.reSend);
    
    if (_authenticate()) {
      //TODO:
      resultEntity.content = true;
      return resultEntity;
    } else {
      _response(code: ChatProtocolCode.reject, content: 'password');
      resultEntity.content = false;
      return resultEntity;
    }
  }

  @override
  HandleResultEntity handleReject() {
    HandleResultEntity resultEntity =
        HandleResultEntity(code: ChatProtocolCode.reject);
   
    if (_authenticate()) {
      //TODO:
      resultEntity.content = true;
      return resultEntity;
    } else {
      resultEntity.content = false;
      return resultEntity;
    }
  }

  @override
  Future<void> dispose() async {
    await super.close();
    await _webSocket?.close();
  }

  @override
  get entity => protocolEntity;

  @override
  void setEntity(entity) {
    protocolEntity = entity;
  }
}
