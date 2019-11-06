import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class RequestEntity {
  static final emptyRequestEntity = RequestEntity(username: '');
  final String username;
  //Image avatar;
  String overview;
  DateTime timestamp;
  RequestEntity({
    //this.avatar,
    @required
    this.username,
    this.overview,
    this.timestamp,
  });
  RequestEntity.fromMap(Map<String, dynamic> map)
      : username = map['username'],
        // avatar=Image.memory(base64.decode(map['avatar'])),
        overview = map['overview'],
        timestamp = DateTime.parse(map['timestamp']);
  Map<String, dynamic> toMap() => <String, dynamic>{
        'username': username,
        'overview': overview,
        'timestamp': timestamp.toString(),
      };
  @override
  int get hashCode => hashValues(username, timestamp);
  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final RequestEntity typedOther = other;
    return username == typedOther.username;
  }

  @override
  String toString() => 'RequestEntity( ${toMap().toString()} )';
}
