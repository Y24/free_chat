import 'dart:convert';

import 'package:free_chat/protocol/entity/base_protocol_entity.dart';

class AccountHeadEntity extends BaseHeadEntity {
  AccountHeadEntity({dynamic id, dynamic code, DateTime timestamp})
      : super(
          id: id,
          code: code,
          timestamp: timestamp,
        );
  AccountHeadEntity.fromJson(Map<String, dynamic> json) : super.fromJson(json);
  @override
  Map<String, dynamic> toJson() => super.toJson();
}

class AccountBodyEntity extends BaseBodyEntity {
  AccountBodyEntity({String content}) : super(content: content);
  AccountBodyEntity.fromJson(Map<String, dynamic> json) : super.fromJson(json);
  @override
  Map<String, dynamic> toJson() => super.toJson();
}

class AccountProtocolEntity {
  AccountHeadEntity head;
  AccountBodyEntity body;
  AccountProtocolEntity({this.head, this.body});
  AccountProtocolEntity.fromJson(Map<String, dynamic> j)
      : assert(j != null),
        head = AccountHeadEntity.fromJson(json.decode(j['head'])),
        body = AccountBodyEntity.fromJson(json.decode(j['body']));
  Map<String, dynamic> toJson() => {
        'head': json.encode(head.toJson()),
        'body': json.encode(body.toJson()),
      };
}