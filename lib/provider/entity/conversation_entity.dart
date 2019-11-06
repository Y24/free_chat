import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:free_chat/UI/home_messages_page.dart';
import 'package:free_chat/util/ui/slide_item.dart';

class ConversationEntity {
  static final emptyConversationEntity = ConversationEntity(username: '');
  final String username;
  //Image avatar;
  String alias;
  String overview;
  DateTime timestamp;
  ConversationEntity({
    //this.avatar,
    @required
    this.username,
    this.alias,
    this.overview,
    this.timestamp,
  });
  ConversationEntity.fromMap(Map<String, dynamic> map)
      : username = map['username'],
        // avatar=Image.memory(base64.decode(map['avatar'])),
        alias = map['alias'],
        overview = map['overview'],
        timestamp = DateTime.parse(map['timestamp']);
  Map<String, dynamic> toMap() => <String, dynamic>{
        'username': username,
        'alias': alias,
        'overview': overview,
        'timestamp': timestamp.toString(),
      };
   SlideItem toSlideItem(BuildContext context, final int index) {
    return SlideItem(
        child: toListTile(context),
        onTap: () {
          HomeMessagesPage.of(context)
              .enterConversation(context, username: username);
        },
        menu: [
          SlideMenuItem(
            height: 60,
            color: Colors.grey,
            child: Center(child: Text('Delete')),
            onTap: () {
              HomeMessagesPage.of(context).deleteConversation(index);
            },
          ),
          SlideMenuItem(
            height: 60,
            color: Colors.blue,
            child: Center(child: Text('Star')),
            onTap: () {
              HomeMessagesPage.of(context).starConversation(index);
            },
          ),
        ]);
  }

  ListTile toListTile(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage('res/images/logo.png'),
      ),
      title: Text(alias),
      subtitle: Text(overview),
      trailing: Text(timestamp.toString().substring(5,16)),
    );
  }
  @override
  int get hashCode => hashValues(username, alias);
  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final ConversationEntity typedOther = other;
    return username == typedOther.username;
  }

  @override
  String toString() => 'ConversationEntity( ${toMap().toString()} )';
}
