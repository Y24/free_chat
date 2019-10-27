import 'package:flutter/material.dart';
import 'package:free_chat/UI/profile_page.dart';
import 'package:free_chat/util/ui/page_tansitions/fade_route.dart';
import 'package:free_chat/util/ui/page_tansitions/slide_route.dart';
import 'package:free_chat/util/ui/slide_item.dart';

class MessageEntity {
  final String imgUrl;
  final int userId;
  final String alias;
  final String subTitle;
  final String trailing;
  const MessageEntity({
    this.imgUrl,
    this.userId,
    this.alias,
    this.subTitle,
    this.trailing,
  });
  MessageEntity.fromJson(final Map<String, String> json)
      : assert(json != null),
        imgUrl = json['imgUrl'],
        userId = int.parse(json['userId']),
        alias = json['title'],
        subTitle = json['subTitle'],
        trailing = json['trailing'];
  Map<String, String> toJson() => {
        'imgUrl': imgUrl,
        'userId': userId.toString(),
        'alias': alias,
        'subTitle': subTitle,
        'trailing': trailing,
      };
  SlideItem toSlideItem(BuildContext context) {
    return SlideItem(
        child: toListTile(context),
        onTap: () {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('child tapped!'),
          ));
        },
        menu: [
          SlideMenuItem(
            height: 60,
            color: Colors.grey,
            child: Center(child: Text('Delete')),
            onTap: () {
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text('Delete tapped!'),
              ));
            },
          ),
          SlideMenuItem(
            height: 60,
            color: Colors.blue,
            child: Center(child: Text('Star')),
            onTap: () {
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text('Star tapped!'),
              ));
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
      subtitle: Text(subTitle),
      trailing: Text(trailing),
    );
  }
}
