import 'dart:convert';
import 'dart:io';

import 'package:free_chat/entity/backend/handle_result_entity.dart';
import 'package:free_chat/entity/enums.dart';
import 'package:free_chat/entity/history_entity.dart';
import 'package:free_chat/protocol/entity/chat_protocol_entity.dart';
import 'package:free_chat/protocol/handler/base_protocol_handler.dart';

abstract class IChatProtocolHandler implements IProtocolHandler {
  Future<HandleResultEntity> handleNewSend();
  Future<HandleResultEntity> handleAccept();
  Future<HandleResultEntity> handleReSend();
  Future<HandleResultEntity> handleReject();
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
  Future<HandleResultEntity> handle(WebSocket webSocket) async {
    _webSocket = webSocket;
    switch (protocolEntity.head.code as ChatProtocolCode) {
      case ChatProtocolCode.newSend:
        return await handleNewSend();
      case ChatProtocolCode.reSend:
        return await handleReSend();
      case ChatProtocolCode.accept:
        return await handleAccept();
      case ChatProtocolCode.reject:
        return await handleReject();
      default:
        print('Here is a bug to be fixed');
        return null;
    }
  }

  Future<bool> _authenticate() async => true;
  void _response({ChatProtocolCode code, String content}) {
    _webSocket.add(json.encode(ChatProtocolEntity(
      head: ChatHeadEntity(
        id: id,
        code: code,
        timestamp: DateTime.now(),
        from: from,
        to: to,
        groupChatFlag: groupChatFlag,
      ),
      body: ChatBodyEntity(content: content),
    ).toJson()));
  }

  @override
  Future<HandleResultEntity> handleNewSend() async {
    HandleResultEntity resultEntity =
        HandleResultEntity(code: ChatProtocolCode.newSend);
    if (!await init()) {
      _response(code: ChatProtocolCode.reject, content: 'server');
      resultEntity.content = {
        'status': SendStatus.serverError,
        'entity': HistoryEntity(
          id: protocolEntity.head.id,
          username: protocolEntity.head.to,
          content: protocolEntity.body.content,
          isOthers: true,
          timestamp: protocolEntity.head.timestamp,
        ),
      };
      return resultEntity;
    }
    if (await _authenticate()) {
      //TODO:
      _response(code: ChatProtocolCode.accept, content: 'Free Chat');
      resultEntity.content = {
        'status': SendStatus.success,
        'entity': HistoryEntity(
          id: protocolEntity.head.id,
          username: protocolEntity.head.to,
          content: protocolEntity.body.content,
          isOthers: true,
          timestamp: protocolEntity.head.timestamp,
        ),
      };
      return resultEntity;
    } else {
      _response(code: ChatProtocolCode.reject, content: 'password');
      resultEntity.content = {
        'status': SendStatus.reject,
        'entity': HistoryEntity(
          id: protocolEntity.head.id,
          username: protocolEntity.head.to,
          content: protocolEntity.body.content,
          isOthers: true,
          timestamp: protocolEntity.head.timestamp,
        ),
      };
      return resultEntity;
    }
  }

  @override
  Future<HandleResultEntity> handleAccept() async {
    HandleResultEntity resultEntity =
        HandleResultEntity(code: ChatProtocolCode.accept);
    if (!await init()) {
      _response(code: ChatProtocolCode.reject, content: 'server');
      resultEntity.content = -protocolEntity.head.id;
      return resultEntity;
    }
    if (await _authenticate()) {
      resultEntity.content = protocolEntity.head.id;
      return resultEntity;
    } else {
      resultEntity.content = -protocolEntity.head.id;
      return resultEntity;
    }
  }

  @override
  Future<HandleResultEntity> handleReSend() async {
    HandleResultEntity resultEntity =
        HandleResultEntity(code: ChatProtocolCode.reSend);
    if (!await init()) {
      _response(code: ChatProtocolCode.reject, content: 'server');
      resultEntity.content = false;
      return resultEntity;
    }
    if (await _authenticate()) {
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
  Future<HandleResultEntity> handleReject() async {
    HandleResultEntity resultEntity =
        HandleResultEntity(code: ChatProtocolCode.reject);
    if (!await init()) {
      _response(code: ChatProtocolCode.reject, content: 'server');
      resultEntity.content = false;
      return resultEntity;
    }
    if (await _authenticate()) {
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
