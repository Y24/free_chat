abstract class MysqlConf {
  static final String host = 'y24.org.cn';
  static final int port = 3306;
  static final String user = 'y24';
  static final String password = '*';
  static final String db = 'free_chat';

  /// The timeout for connecting to the database and for all database operations.
  static final Duration timeout = const Duration(seconds: 2);
}
