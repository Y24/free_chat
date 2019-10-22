import 'package:free_chat/services/mysql_service.dart';
import 'package:mysql1/mysql1.dart';

import '../enums.dart';
import '../role_string.dart';

class Account {
  static const String sqlCreateUserTable = '''
 create table if not exists USER(
	USERNAME varchar(20) not null primary key,
	PASSWORD varchar(50) null,
	ROLE varchar(10) null,
	ACCOUNTNONEXPIRED tinyint(1) null,
	ACCOUNTNONLOCKED tinyint(1) null,
	CREDENTIALSNONEXPIRED tinyint(1) null,
	ENABLED tinyint(1) null
  )
  charset=utf8;
''';
  static const String sqlSelectAllUsers = '''
  select * from USER;
''';

  Future<Results> createUserTable({
    MySqlConnection connection,
  }) async {
    return connection.query(sqlCreateUserTable);
  }

  static Future<Results> selectAllUsers({
    MySqlConnection connection,
  }) async {
    return await connection.query(sqlSelectAllUsers);
  }

  static Future<Results> insertUser({
    MySqlConnection connection,
    final String username,
    final String password,
    final Role role,
  }) async {
    return await connection.query('insert into USER values (?,?,?,?,?,?,?)',
        [username, password, RoleString.string(role), 1, 1, 1, 1]);
  }

  static Future<Results> updateUser({
    MySqlConnection connection,
    final String username,
    final String password,
  }) async {
    return await connection.query(
        'update USER set password = ? where username = ?',
        [password, username]);
  }

  static Future<Results> dropUser({
    MySqlConnection connection,
    final String username,
  }) async {
    return await connection.query('delete from USER username = ?', [username]);
  }

  static Future<Results> selectUserByName(
      {MySqlConnection connection, final String name}) async {
    return await connection.query(
        'select username, password from USER where username = ?', [name]);
  }
}
