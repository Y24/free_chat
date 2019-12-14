import 'package:flutter/foundation.dart';
import 'package:free_chat/provider/base_provider.dart';
import 'package:free_chat/provider/entity/configuration_entity.dart';
import 'package:free_chat/provider/entity/provider_code.dart';
import 'package:free_chat/provider/entity/provider_entity.dart';
import 'package:free_chat/util/sql_util.dart';
import 'package:sqflite/sqflite.dart';

abstract class IConfigurationProvider implements IProvider {
  Future query();
  Future update();
}

/// Provide the configuration data.
class ConfigurationProvider extends BaseProvider
    implements IConfigurationProvider {
  static final _defConfigurationValues = {
    'language': 'en',
    'theme': 'light',
    'primaryColor': 'blue',
  };
  final String username;
  ProviderEntity _providerEntity;
  ConfigurationProvider({@required this.username});
  @override
  Future close() async {
    if (db?.isOpen ?? false) await db?.close();
  }

  @override
  String get dbName => 'configuration';

  @override
  get entity => _providerEntity;

  @override
  Future<bool> init() async {
    try {
      db = await openDatabase(
        '$ownerName/$dbName.db',
        version: 1,
        onOpen: (db) {
          print('onOpen: $ownerName/$dbName.db');
        },
        onCreate: (db, version) async {
          print('onCreate: $ownerName/$dbName.db');
          tables.forEach((tableName, columnNames) async {
            final sql = SqlUtil.getSql(tableName, columnNames);
            await db.execute(sql);
          });
          _defConfigurationValues.forEach((key, value) async {
            try {
              final timeStr = DateTime.now().toString();
              await db.insert('configuration', {
                'key': key,
                'content': value,
                'create_timestamp': timeStr,
                'last_modified': timeStr,
              });
            } catch (e) {
              print(
                  'Error accours when onCreate at Configuration initial work: $e');
            }
          });
        },
      );
      return true;
    } catch (e) {
      print('when init db ,catch e: $e');
      return false;
    }
  }

  @override
  String get ownerName => username;

  @override
  Future provide() async {
    switch (entity.code as ConfigurationProviderCode) {
      case ConfigurationProviderCode.updateLanguage:
      case ConfigurationProviderCode.updateTheme:
      case ConfigurationProviderCode.updatePrimaryColor:
        return await update();
        break;
      case ConfigurationProviderCode.queryLanguage:
      case ConfigurationProviderCode.queryTheme:
      case ConfigurationProviderCode.queryPrimaryColor:
        return await query();
        break;
      default:
        print('configuration provider provide error');
    }
  }

  @override
  void setEntity(entity) {
    _providerEntity = entity;
  }

  @override
  Map<String, List<String>> get tables => const <String, List<String>>{
        'configuration': [
          'key',
          'content',
          'create_timestamp',
          'last_modified'
        ],
      };

  @override
  Future query() async {
    final key =
        _getConfigurationKeyFromCode(entity.code as ConfigurationProviderCode);
    try {
      final result = await db.query('configuration',
          columns: tables['configuration'], where: 'key = ?', whereArgs: [key]);
      assert(result.length == 1,
          'Well, there should exsit exact one configuration with key: $key');
      return ConfigurationEntity.fromMap(result[0]);
    } catch (e) {
      print('error accours when query configuration: $e');
      return ConfigurationEntity.emptyConfigurationEntity;
    }
  }

  @override
  Future update() async {
    final ConfigurationEntity content =
        _providerEntity.content as ConfigurationEntity;
    final key = _getConfigurationKeyFromCode(_providerEntity.code);
    try {
      await db.update('configuration', content.toMap(),
          where: 'key = ?', whereArgs: [key]);
      return true;
    } catch (e) {
      print('error accours when update configuration: $e');
      return false;
    }
  }
}

String _getConfigurationKeyFromCode(ConfigurationProviderCode code) => {
      ConfigurationProviderCode.queryLanguage: 'language',
      ConfigurationProviderCode.updateLanguage: 'language',
      ConfigurationProviderCode.queryTheme: 'theme',
      ConfigurationProviderCode.updateTheme: 'theme',
      ConfigurationProviderCode.queryPrimaryColor: 'primaryColor',
      ConfigurationProviderCode.updatePrimaryColor: 'primaryColor',
    }[code];
