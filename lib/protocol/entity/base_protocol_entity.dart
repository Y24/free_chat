import 'package:free_chat/util/function_pool.dart';

abstract class BaseHeadEntity {
  final dynamic id;
  final dynamic code;
  final DateTime timestamp;
  BaseHeadEntity({this.id, this.code, this.timestamp});
  BaseHeadEntity.fromJson(Map<String, dynamic> json)
      : assert(json != null),
        id = json['id'],
        code = FunctionPool.getProtocolCodeByStr(json['code']),
        timestamp = DateTime.parse(json['timestamp']);
  Map<String, dynamic> toJson() => {
        'id': id,
        'code': FunctionPool.getStrByProtocolCode(code),
        'timestamp': timestamp.toString(),
      };
}

abstract class BaseBodyEntity {
  final String content;
  BaseBodyEntity({this.content});
  BaseBodyEntity.fromJson(Map<String, dynamic> json)
      : assert(json != null),
        content = json['content'];
  Map<String, dynamic> toJson() => {
        'content': content,
      };
}
