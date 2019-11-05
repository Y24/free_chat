import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:free_chat/util/ui/profile_body_list_title.dart';

class ProfileEntity {
  static final emptyProfileEntity = ProfileEntity(username: '');
  String username;
  List labels;
  // likes shares notes
  List lsnCount;
  // body list title
  List infos;
  ProfileEntity({this.username, this.labels, this.lsnCount, this.infos});
  ProfileEntity.fromMap(Map<String, dynamic> map)
      : assert(map != null),
        username = map['username'],
        labels = json.decode(map['labels']),
        lsnCount = json.decode(map['lsnCount']),
        infos = (json.decode(map['infos']))
            .map((s) => ProfileBodyListTitle.fromJson(json.decode(s)))
            .toList();
  toMap() => {
        'username': username,
        'labels': json.encode(labels),
        'lsnCount': json.encode(lsnCount),
        'infos':
            json.encode(infos.map((f) => json.encode(f.toJson())).toList()),
      };
  @override
  int get hashCode => hashValues(username, labels);
  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final ProfileEntity typedOther = other;
    return username == typedOther.username;
  }

  @override
  String toString() =>
      'ProfileEntity( { username: $username, labels: $labels, lsnCount: $lsnCount} )';
}
