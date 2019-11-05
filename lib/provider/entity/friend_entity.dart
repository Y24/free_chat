
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class FriendEntity {
  static final emptyFriendEntity = FriendEntity(username: '');
  final String username;
  //Image avatar;
  String alias;
  String overview;
  FriendEntity({
    //this.avatar,
    this.username,
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
