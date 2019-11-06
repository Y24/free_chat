import 'package:free_chat/provider/base_provider.dart';
import 'package:free_chat/provider/entity/friend_entity.dart';
import 'package:free_chat/provider/entity/provider_code.dart';
import 'package:free_chat/provider/entity/provider_entity.dart';
import 'package:free_chat/util/sql_util.dart';
import 'package:sqflite/sqflite.dart';

abstract class IFriendProvider implements IProvider {
  Future addFriend();
  Future updateFriend();
  Future deleteFriend();
  Future queryFriend();
  Future queryAllFriend();
}

class FriendProvier extends BaseProvider implements IFriendProvider {
  final String username;
  ProviderEntity _providerEntity;
  FriendProvier({this.username});
  @override
  Future close() async {
     if (db?.isOpen ?? false) await db?.close();
  }

  @override
  String get dbName => 'friend';

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
    switch (entity.code as FriendProviderCode) {
      case FriendProviderCode.addFriend:
        return await addFriend();
      case FriendProviderCode.updateFriend:
        return await updateFriend();
      case FriendProviderCode.deleteFriend:
        return await deleteFriend();
      case FriendProviderCode.queryFriend:
        return await queryFriend();
      case FriendProviderCode.queryAllFriend:
        return await queryAllFriend();
      default:
        print('friend provider provide error');
    }
  }

  @override
  void setEntity(entity) {
    _providerEntity = entity;
  }

  @override
  Map<String, List<String>> get tables => const <String, List<String>>{
        'friend': ['username', 'alias', 'overview'],
      };

  @override
  Future addFriend() async {
    if (await queryFriend() != FriendEntity.emptyFriendEntity)
      return false;
    else {
      try {
        await db.insert('friend', entity.content.toMap());
        return true;
      } catch (e) {
        return false;
      }
    }
  }

  @override
  Future deleteFriend() async {
    final result = await db.delete('friend',
        where: 'username = ?', whereArgs: [entity.content.username]);
    assert(result <= 1,
        'Well, there should not exsit more than one friend with username: ${entity.content.username}');
    return result == 1;
  }

  @override
  Future queryAllFriend() async {
    final result = await db.query(
      'friend',
      columns: tables['friend'],
    );
    if (result.isEmpty)
      return [];
    else
      return result.map((r) => FriendEntity.fromMap(r)).toList();
  }

  @override
  Future queryFriend() async {
    FriendEntity friendEntity = entity.content;
    final result = await db.query('friend',
        columns: tables['friend'],
        where: 'username = ?',
        whereArgs: [friendEntity.username]);
    assert(result.length <= 1,
        'Well, there should not exsit more than one friend with username: ${entity.content.username}');
    if (result.isEmpty)
      return FriendEntity.emptyFriendEntity;
    else
      return FriendEntity.fromMap(result[0]);
  }

  @override
  Future updateFriend() async {
    final result = await db.update('friend', entity.content.toMap(),
        where: 'username = ?', whereArgs: [entity.content.username]);
    assert(result <= 1,
        'Well, there should not exsit more than one friend with username: ${entity.content.username}');
    return result == 1;
  }
}
