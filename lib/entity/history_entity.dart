import 'package:flutter/material.dart';
import 'package:free_chat/entity/enums.dart';
import 'package:free_chat/util/function_pool.dart';

class HistoryEntity {
  final id;
  final String avatarData;
  final String username;
  final String content;
  final bool isOthers;
  final DateTime timestamp;
  MessageSendStatus status;
  HistoryEntity({
    this.id,
    this.avatarData,
    this.username,
    this.content,
    this.isOthers,
    this.timestamp,
    this.status,
  });
  HistoryEntity.fromJson(final Map<String, dynamic> json)
      : assert(json != null),
        id = json['id'],
        avatarData = json['avatarData'],
        username = json['username'],
        isOthers = json['alias'],
        content = json['content'],
        timestamp = json['timestamp'],
        status = FunctionPool.getMessageSendStatusByStr(json['status']);
  Map<String, dynamic> toJson() => {
        'id': id,
        'avatarData': avatarData,
        'username': username,
        'isOthers': isOthers,
        'content': content,
        'timestamp': timestamp,
        'status': FunctionPool.getStrByMessageSendStatus(status),
      };
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
    switch (status) {
      case MessageSendStatus.processing:
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
              )),
        );
      case MessageSendStatus.success:
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Icon(
            Icons.check_box,
            color: Colors.green,
          ),
        );
      case MessageSendStatus.failture:
        return GestureDetector(
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
