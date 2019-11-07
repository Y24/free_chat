import 'dart:convert';
import 'dart:io';

import 'package:free_chat/protocol/entity/chat_protocol_entity.dart';
import 'package:free_chat/protocol/sender/base_protocol_sender.dart';

abstract class IChatProtocolSender implements IProtocolSender {}

class ChatProtocolSender extends BaseProtocolSender
    implements IChatProtocolSender {
  final username;
  final String password;
  final String from;
  final String to;
  final bool groupChatFlag;
  ChatProtocolEntity protocolEntity;
  ChatProtocolSender(
      {this.username, this.password, this.from, this.to, this.groupChatFlag});
  @override
  String get urlPrefix => 'chat/$username';
  @override
  Future<WebSocket> init() {
    return super.setUp();
  }

  @override
  send() {
    try {
      webSocket.add(json.encode(protocolEntity.toJson()));
      return true;
    } catch (e) {
      print('chat _send error: $e');
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    await super.close();
  }

  @override
  get entity => protocolEntity;

  @override
  void setEntity(entity) {
    protocolEntity = entity;
  }
}
