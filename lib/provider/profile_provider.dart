import 'package:free_chat/provider/base_provider.dart';
import 'package:free_chat/provider/entity/profile_entity.dart';
import 'package:free_chat/provider/entity/provider_code.dart';
import 'package:free_chat/provider/entity/provider_entity.dart';
import 'package:free_chat/util/sql_util.dart';
import 'package:sqflite/sqflite.dart';

abstract class IProfileProvider implements IProvider {
  Future addProfile();
  Future updateProfile();
  Future deleteProfile();
  Future queryProfile();
  Future queryAllProfile();
}

class ProfileProvider extends BaseProvider implements IProfileProvider {
  final String username;
  ProviderEntity _providerEntity;
  ProfileProvider({this.username});

  @override
  Future close() async {
     if (db?.isOpen ?? false) await db?.close();
  }

  @override
  String get dbName => 'profile';

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
    switch (entity.code as ProfileProviderCode) {
      case ProfileProviderCode.addProfile:
        return await addProfile();
      case ProfileProviderCode.updateProfile:
        return await updateProfile();
      case ProfileProviderCode.deleteProfile:
        return await deleteProfile();
      case ProfileProviderCode.queryProfile:
        return await queryProfile();
      case ProfileProviderCode.queryAllProfile:
        return await queryAllProfile();
      default:
        print('profile provider provide error');
    }
  }

  @override
  void setEntity(entity) {
    _providerEntity = entity;
  }

  @override
  Map<String, List<String>> get tables => const <String, List<String>>{
        'profile': ['username', 'labels', 'lsnCount', 'infos'],
      };
  @override
  Future queryAllProfile() async {
    final result = await db.query(
      'profile',
      columns: tables['profile'],
    );
    if (result.isEmpty)
      return [];
    else
      return result.map((r) => ProfileEntity.fromMap(r)).toList();
  }

  @override
  Future queryProfile() async {
    ProfileEntity profileEntity = entity.content;
    final result = await db.query('profile',
        columns: tables['profile'],
        where: 'username = ?',
        whereArgs: [profileEntity.username]);
    assert(result.length <= 1,
        'Well, there should not exsit more than one profile with username: ${entity.content.username}');
    if (result.isEmpty)
      return ProfileEntity.emptyProfileEntity;
    else
      return ProfileEntity.fromMap(result[0]);
  }

  @override
  Future updateProfile() async {
    final result = await db.update('profile', entity.content.toMap(),
        where: 'username = ?', whereArgs: [entity.content.username]);
    assert(result <= 1,
        'Well, there should not exsit more than one profile with username: ${entity.content.username}');
    return result == 1;
  }

  @override
  Future addProfile() async {
    if (await queryProfile() != ProfileEntity.emptyProfileEntity)
      return false;
    else {
      try {
        await db.insert('profile', entity.content.toMap());
        return true;
      } catch (e) {
        print('error when add profile: $e');
        return false;
      }
    }
  }

  @override
  Future deleteProfile() async {
    final result = await db.delete('profile',
        where: 'username = ?', whereArgs: [entity.content.username]);
    assert(result <= 1,
        'Well, there should not exsit more than one profile with username: ${entity.content.username}');
    return result == 1;
  }
}
