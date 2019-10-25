import 'dart:io';

import 'package:flutter/material.dart';
import 'package:free_chat/UI/profile_page.dart';
import 'package:free_chat/util/ui/page_tansitions/slide_route.dart';

class ContactsEntity {
  final String imgUrl;
  final int userId;
  final String alias;
  final String subTitle;
  const ContactsEntity({
    this.imgUrl,
    this.userId,
    this.alias,
    this.subTitle,
  });
  ContactsEntity.fromJson(final Map<String, String> json)
      : assert(json != null),
        imgUrl = json['imgUrl'],
        userId = int.parse(json['userId']),
        alias = json['title'],
        subTitle = json['subTitle'];
  Map<String, String> toJson() => {
        'imgUrl': imgUrl,
        'userId': userId.toString(),
        'alias': alias,
        'subTitle': subTitle,
      };
  ListTile toListTile(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage('res/images/logo.png'),
      ),
      title: Text(alias),
      subtitle: Text(subTitle),
      onTap: () {
        Navigator.of(context)
            .push(SlideRightRoute(page: ProfilePage(userId: userId)));
      },
    );
  }
}
