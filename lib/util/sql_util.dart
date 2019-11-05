abstract class SqlUtil {
  static String getSql(String tableName, List<String> columnNames) {
    StringBuffer sqlBuffer = StringBuffer(
        'create table $tableName ( id integer primary key autoincrement, ');
    sqlBuffer.writeAll(
        columnNames.map((columnName) => '$columnName text not null, '));
    return sqlBuffer.toString().substring(0, sqlBuffer.length - 2) + ' )';
  }
}
