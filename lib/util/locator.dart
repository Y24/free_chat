/* 
GetIt locator;
void setupLocator() {
  locator = GetIt.instance;
  locator.registerLazySingleton<ConnectionSettings>(
    () => ConnectionSettings(
      host: MysqlConf.host,
      port: MysqlConf.port,
      user: MysqlConf.user,
      password: MysqlConf.password,
      db: MysqlConf.db,
      timeout: MysqlConf.timeout,
    ),
    instanceName: 'ConnectionSettings',
  );
 */
