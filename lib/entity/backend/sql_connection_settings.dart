import 'package:mysql1/mysql1.dart';

class SqlConnectionSettings {
  SqlConnectionSettings._();
  static instance() {
    return ConnectionSettings(
      host: 'y24.org.cn',
      port: 3306,
      user: 'y24',
      password: '*', // /Note: out of date.
      db: 'free_chat',
      timeout: const Duration(seconds: 3),
    );
  }
}
