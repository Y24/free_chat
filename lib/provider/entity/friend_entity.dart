import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:free_chat/UI/profile_page.dart';
import 'package:free_chat/provider/account_provider.dart';
import 'package:free_chat/provider/base_provider.dart';
import 'package:free_chat/provider/entity/provider_code.dart';
import 'package:free_chat/provider/entity/provider_entity.dart';
import 'package:free_chat/util/ui/page_tansitions/fade_route.dart';

class FriendEntity {
  static final emptyFriendEntity = FriendEntity(username: '');
  final String username;
  //Image avatar;
  String alias;
  String overview;
  FriendEntity({
    //this.avatar,
    @required this.username,
    this.alias,
    this.overview,
  });
  FriendEntity.fromMap(Map<String, dynamic> map)
      : username = map['username'],
        // avatar=Image.memory(base64.decode(map['avatar'])),
        alias = map['alias'],
        overview = map['overview'];
  Map<String, dynamic> toMap() => <String, dynamic>{
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
      onTap: () async {
        IProvider provider = AccountProvider();
        await provider.init();
        provider
            .setEntity(ProviderEntity(code: AccountProviderCode.queryLogined));
        final hostUsername = (await provider.provide()).username;
        print('logined: $hostUsername');
        await provider.close();
        Navigator.of(context).push(FadeRoute(
            page: ProfilePage(hostUsername: hostUsername, username: username)));
      },
    );
  }

  @override
  int get hashCode => hashValues(username, alias);
  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final FriendEntity typedOther = other;
    return username == typedOther.username;
  }

  @override
  String toString() =>
      'FriendEntity( { username: $username, alias: $alias, overview: $overview} )';
}
