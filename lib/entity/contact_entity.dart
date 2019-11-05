import 'package:flutter/material.dart';
import 'package:free_chat/UI/profile_page.dart';
import 'package:free_chat/util/ui/page_tansitions/fade_route.dart';

class ContactEntity {
  final String avatarUrl;
  final String username;
  final String alias;
  final String overview;
  const ContactEntity({
    this.avatarUrl,
    this.username,
    this.alias,
    this.overview,
  });
  ContactEntity.fromJson(final Map<String, String> json)
      : assert(json != null),
        avatarUrl = json['avatarUrl'],
        username = json['username'],
        alias = json['alias'],
        overview = json['overview'];
  Map<String, String> toJson() => {
        'avatarUrl': avatarUrl,
        'username': username,
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
            .push(FadeRoute(page: ProfilePage(username: username)));
      },
    );
  }
}
