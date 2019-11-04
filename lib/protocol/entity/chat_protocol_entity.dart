import 'dart:convert';

import 'package:free_chat/protocol/entity/base_protocol_entity.dart';

class ChatHeadEntity extends BaseHeadEntity {
  final String from;
  final String to;
  final bool groupChatFlag;
  final String password;
  ChatHeadEntity({
    dynamic id,
    dynamic code,
    DateTime timestamp,
    this.from,
    this.to,
    this.groupChatFlag,
    this.password,
  }) : super(
          id: id,
          code: code,
          timestamp: timestamp,
        );
  ChatHeadEntity.fromJson(Map<String, dynamic> json)
      : from = json['from'],
        to = json['to'],
        groupChatFlag = json['groupChatFlag'],
        password = json['password'],
        super.fromJson(json);
  @override
  Map<String, dynamic> toJson() {
    var map = super.toJson();
    map['from'] = from;
    map['to'] = to;
    map['groupChatFlag'] = groupChatFlag;
    map['password'] = password;
    return map;
  }
}

class ChatBodyEntity extends BaseBodyEntity {
  ChatBodyEntity({String content}) : super(content: content);
  ChatBodyEntity.fromJson(Map<String, dynamic> json) : super.fromJson(json);
  @override
  Map<String, dynamic> toJson() => super.toJson();
}

class ChatProtocolEntity {
  ChatHeadEntity head;
  ChatBodyEntity body;
  ChatProtocolEntity({this.head, this.body});
  ChatProtocolEntity.fromJson(Map<String, dynamic> j)
      : assert(j != null),
        head = ChatHeadEntity.fromJson(json.decode(j['head'])),
        body = ChatBodyEntity.fromJson(json.decode(j['body']));
  Map<String, dynamic> toJson() => {
        'head': json.encode(head.toJson()),
        'body': json.encode(body.toJson()),
      };
}
