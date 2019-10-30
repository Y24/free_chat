import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:free_chat/entity/enums.dart';
import 'package:free_chat/util/function_pool.dart';

class ChatProtocol {
  static final String protocolName = 'ws';
  static final String urlPrefixStr = 'chat';
  bool _connected = false;
  final int userId;
  final int toId;
  final bool isGroupChat;
  ProtocolEntity protocol;
  //Stream<ProtocolEntity> stream;
  Stream stream;
  WebSocket _webSocket;
  ChatProtocol({
    @required this.userId,
    @required this.toId,
    @required this.isGroupChat,
  });
  bool get connected => _connected;
  Future<bool> setUpWebSocket(String hostname,
      {int port = 2424, Map<String, dynamic> headers}) async {
    assert(connected == false, 'Reset WebSocket is not allowed in my case.');
    try {
      print(
          'begin connecting url: $protocolName://$hostname:$port/$urlPrefixStr/$userId/To/$toId');
      _webSocket = await WebSocket.connect(
          '$protocolName://$hostname:$port/$urlPrefixStr/$userId/To/$toId',
          headers: headers);
      _connected = true;
      print('success');
      stream = _webSocket;
      //  stream = _webSocket.map((s) => ProtocolEntity.fromJson(json.decode(s)));
      //webSocket.add('hello');
      //print('connect WebSocket: ${webSocket.runtimeType}');
    } catch (e) {
      return false;
    }
    return true;
  }

  void newSend({
    @required int id,
    @required String content,
    @required DateTime timestamp,
  }) {
    assert(connected == true, 'Please call setUpWebSocket method before.');
    protocol = ProtocolEntity(
      head: HeadEntity(
        id: id,
        code: ChatProtocolCode.newSend,
        timestamp: timestamp,
        isGroupChat: isGroupChat,
        fromId: userId,
        toId: toId,
      ),
      body: BodyEntity(
        message: Message(
          id: id,
          content: content,
        ),
      ),
    );
    _webSocket.add(json.encode(protocol.toJson()));
  }

  bool close() {
    if (connected) _webSocket.close();
    return connected;
  }
}

class HeadEntity {
  final int id;
  final ChatProtocolCode code;
  final DateTime timestamp;
  final bool isGroupChat;
  final int fromId;
  final int toId;
  HeadEntity({
    @required this.id,
    @required this.code,
    @required this.timestamp,
    @required this.isGroupChat,
    @required this.fromId,
    @required this.toId,
  });
  HeadEntity.fromJson(Map<String, dynamic> j)
      : assert(j != null),
        id = j['id'],
        code = FunctionPool.getChatProtocolCodeByStr(j['code']),
        timestamp = DateTime.parse(j['timestamp']),
        isGroupChat = j['isGroupChat'],
        fromId = j['fromId'],
        toId = j['toId'];
  Map<String, dynamic> toJson() => {
        'id': id,
        'code': FunctionPool.getStrByChatProtocolCode(code),
        'timestamp': timestamp.toString(),
        'isGroupChat': isGroupChat,
        'fromId': fromId,
        'toId': toId,
      };
}

class ProtocolEntity {
  final HeadEntity head;
  final BodyEntity body;
  const ProtocolEntity({@required this.head, @required this.body});
  ProtocolEntity.fromJson(Map<String, dynamic> j)
      : assert(j != null),
        head = HeadEntity.fromJson(json.decode(j['head'])),
        body = BodyEntity.fromJson(json.decode(j['body']));
  Map<String, dynamic> toJson() => {
        'head': json.encode(head.toJson()),
        'body': json.encode(body.toJson()),
      };
}

class BodyEntity {
  final Message message;

  const BodyEntity({@required this.message});
  BodyEntity.fromJson(Map<String, dynamic> j)
      : assert(j != null),
        message = Message.fromJson(json.decode(j['message']));

  Map<String, dynamic> toJson() => {
        'message': json.encode(message.toJson()),
      };
}

class Message {
  final int id;
  final String content;

  const Message({
    @required this.id,
    @required this.content,
  });
  Message.fromJson(final Map<String, dynamic> json)
      : assert(json != null),
        id = json['id'],
        content = json['content'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
      };
}
