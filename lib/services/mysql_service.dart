import 'package:free_chat/configuration/mysql_conf.dart';
import 'package:free_chat/entity/enums.dart';
import 'package:free_chat/util/locator.dart';
import 'package:mysql1/mysql1.dart';

class MysqlService {
  bool _isConnected = false;
  MySqlConnection _connection;
  MySqlConnection get connection => _connection;
  bool get connected => _isConnected;
  Future connect() async {
    _connection = await MySqlConnection.connect(
      ConnectionSettings(
        host: MysqlConf.host,
        port: MysqlConf.port,
        user: MysqlConf.user,
        password: MysqlConf.password,
        db: MysqlConf.db,
        timeout: MysqlConf.timeout,
      ),
    );
    _isConnected = true;
  }

  close() async {
    _connection.close().then((_) {
      _isConnected = false;
    });
  }
}
