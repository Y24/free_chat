import 'package:flutter/material.dart';
import 'package:free_chat/UI/profile_page.dart';
import 'package:free_chat/util/ui/page_tansitions/fade_route.dart';

class ContactEntity {
  final String avatarUrl;
  final int userId;
  final String alias;
  final String overview;
  const ContactEntity({
    this.avatarUrl,
    this.userId,
    this.alias,
    this.overview,
  });
  ContactEntity.fromJson(final Map<String, String> json)
      : assert(json != null),
        avatarUrl = json['avatarUrl'],
        userId = int.parse(json['userId']),
        alias = json['alias'],
        overview = json['overview'];
  Map<String, String> toJson() => {
        'avatarUrl': avatarUrl,
        'userId': userId.toString(),
        'alias': alias,
        'overview': overview,
      };
  ListTile toListTile(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage('res/images/logo.png'),
      ),
      title: Text(alias),
      subtitle: Text(overview),
      onTap: () {
        Navigator.of(context)
            .push(FadeRoute(page: ProfilePage(userId: userId)));
      },
    );
  }
}
