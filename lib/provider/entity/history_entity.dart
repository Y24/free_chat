import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:free_chat/entity/enums.dart';
import 'package:free_chat/util/function_pool.dart';

class HistoryEntity {
  static final emptyHistoryEntity = HistoryEntity(username: '');
  final historyId;
  //final String avatarData;
  final String username;
  final String content;
  final bool isOthers;
  final DateTime timestamp;
  MessageSendStatus status;
  HistoryEntity({
    this.historyId,
    //  this.avatarData,
    this.username,
    this.content,
    this.isOthers,
    this.timestamp,
    this.status,
  });
  HistoryEntity.fromMap(final Map<String, dynamic> map)
      : assert(map != null),
        historyId = int.parse(map['historyId']),
        //avatarData = map['avatarData'],
        username = map['username'],
        isOthers = map['isOthers'] == '1',
        content = map['content'],
        timestamp = DateTime.parse(map['timestamp']),
        status = FunctionPool.getMessageSendStatusByStr(map['status']);
  Map<String, dynamic> toMap() => {
        'historyId': historyId.toString(),
        //'avatarData': avatarData,
        'username': username,
        'isOthers': isOthers ? '1' : '0',
        'content': content,
        'timestamp': timestamp.toString(),
        'status': FunctionPool.getStrByMessageSendStatus(status),
      };
  @override
  int get hashCode => hashValues(historyId, username, timestamp);
  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final HistoryEntity typedOther = other;
    return historyId == typedOther.historyId &&
        username == typedOther.username &&
        timestamp == typedOther.timestamp;
  }

  @override
  String toString() =>
      'HistoryEntity( ${toMap().toString()} )';
}
