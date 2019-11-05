// Color(Colors.blue)

import 'enums.dart';

abstract class RoleString {
  static final Map<Role, String> _map = {
    Role.admin: 'Admin',
    Role.service: 'Service',
    Role.user: 'User',
  };
  static String string(Role role) => _map[role];
  static Role role(String s) => _map.map((r, s) => MapEntry(s, r))[s];
}
