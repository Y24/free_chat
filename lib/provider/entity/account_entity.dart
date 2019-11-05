import 'package:flutter/rendering.dart';
import 'package:free_chat/entity/enums.dart';
import 'package:free_chat/entity/role_string.dart';

class AccountEntity {
  static final emptyAccountEntity = AccountEntity(username: '');
  final String username;
  Role role;
  String password;
  bool loginStatus;
  DateTime lastLoginTimestamp;
  DateTime lastLogoutTimestamp;
  AccountEntity({
    this.username,
    this.password,
    this.role,
    this.loginStatus,
    this.lastLoginTimestamp,
    this.lastLogoutTimestamp,
  });
  AccountEntity.fromMap(Map<String, dynamic> map)
      : username = map['username'],
        role = RoleString.role(map['role']),
        password = map['password'],
        loginStatus = map['loginStatus'] == 1,
        lastLoginTimestamp = DateTime.parse(map['lastLoginTimestamp']),
        lastLogoutTimestamp = DateTime.parse(map['lastLogoutTimestamp']);
  Map<String, dynamic> toMap() => <String, dynamic>{
        'username': username,
        'role': RoleString.string(role),
        'password': password,
        'loginStatus': loginStatus ? 1 : 0,
        'lastLoginTimestamp': lastLoginTimestamp.toString(),
        'lastLogoutTimestamp': lastLogoutTimestamp.toString(),
      };
  @override
  int get hashCode => hashValues(username, role);
  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final AccountEntity typedOther = other;
    return username == typedOther.username;
  }

  @override
  String toString() => 'AccountEntity( { username: $username } )';
}
