import 'package:flutter/material.dart';
import 'package:free_chat/UI/home_messages_page.dart';
import 'package:free_chat/util/ui/slide_item.dart';

class MessageEntity {
  final String avatarUrl;
  final String username;
  final String alias;
  final String overview;
  final String timestamp;
  const MessageEntity({
    this.avatarUrl,
    this.username,
    this.alias,
    this.overview,
    this.timestamp,
  });
  MessageEntity.fromJson(final Map<String, dynamic> json)
      : assert(json != null),
        avatarUrl = json['avatarUrl'],
        username = json['username'],
        alias = json['alias'],
        overview = json['overview'],
        timestamp = json['timestamp'];
  Map<String, dynamic> toJson() => {
        'avatarUrl': avatarUrl,
        'username': username,
        'alias': alias,
        'overview': overview,
        'timestamp': timestamp,
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
      trailing: Text(timestamp),
    );
  }
}
