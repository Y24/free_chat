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
    @required this.username,
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
  String toString() => 'HistoryEntity( ${toMap().toString()} )';
}

class OneselfHistoryItem extends StatefulWidget {
  const OneselfHistoryItem({
    Key key,
    @required this.content,
    @required this.initTimestamp,
    this.status,
  }) : super(key: key);
  final DateTime initTimestamp;
  final String content;
  final MessageSendStatus status;
  @override
  _OneselfHistoryItemState createState() => _OneselfHistoryItemState();
}

class _OneselfHistoryItemState extends State<OneselfHistoryItem> {
  DateTime timestamp;
  @override
  void initState() {
    super.initState();
    timestamp = widget.initTimestamp;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        SizedBox(
          width: 30,
        ),
        Container(child: buildProcessIndicator(status: widget.status)),
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              color: Colors.blue,
            ),
            child: Text(widget.content,
                style: TextStyle(fontSize: 16, color: Colors.white)),
            padding: const EdgeInsets.all(10.0),
          ),
        ),
        Padding(
          child:
              CircleAvatar(backgroundImage: AssetImage('res/images/logo.png')),
          padding: EdgeInsets.only(left: 8, right: 14),
        ),
      ],
    );
  }

  buildProcessIndicator({MessageSendStatus status}) {
    final processing = Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
          )),
    );
    final failture = GestureDetector(
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Icon(
          Icons.info,
          color: Colors.red,
        ),
      ),
      onTap: () {
        print('Tapped');
      },
    );
    final success = Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Icon(
        Icons.check_box,
        color: Colors.green,
      ),
    );
    switch (status) {
      case MessageSendStatus.processing:
        if (timestamp.difference(DateTime.now()).abs().inSeconds < 4)
          return processing;
        return failture;
      case MessageSendStatus.success:
        if (timestamp.difference(DateTime.now()).abs().inSeconds < 20)
          return success;
        return null;
      case MessageSendStatus.failture:
        return failture;
      default:
        return null;
    }
  }
}

class OthersHistoryItem extends StatelessWidget {
  const OthersHistoryItem({
    Key key,
    @required this.content,
    @required this.timestamp,
  }) : super(key: key);
  final DateTime timestamp;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          child:
              CircleAvatar(backgroundImage: AssetImage('res/images/logo.png')),
          padding: EdgeInsets.only(left: 14, right: 8),
        ),
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              color: Colors.grey[200],
            ),
            child: Text(content,
                style: TextStyle(fontSize: 16, color: Colors.blue)),
            padding: const EdgeInsets.all(10.0),
          ),
        ),
        SizedBox(width: 30),
      ],
    );
  }
}
