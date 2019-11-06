/// Provide the conversation data.
import 'package:free_chat/provider/base_provider.dart';
import 'package:free_chat/provider/entity/conversation_entity.dart';
import 'package:free_chat/provider/entity/provider_code.dart';
import 'package:free_chat/provider/entity/provider_entity.dart';
import 'package:free_chat/util/sql_util.dart';
import 'package:sqflite/sqflite.dart';

abstract class IConversationProvider implements IProvider {
  Future addConversation();
  Future updateConversation();
  Future deleteConversation();
  Future queryConversation();
  Future queryAllConversation();
}

class ConversationProvider extends BaseProvider
    implements IConversationProvider {
  final String username;
  ProviderEntity _providerEntity;
  ConversationProvider({this.username});
  @override
  Future close() async {
     if (db?.isOpen ?? false) await db?.close();
  }

  @override
  String get dbName => 'conversation';

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
    switch (entity.code as ConversationProviderCode) {
      case ConversationProviderCode.addConversation:
        return await addConversation();
      case ConversationProviderCode.updateConversation:
        return await updateConversation();
      case ConversationProviderCode.deleteConversation:
        return await deleteConversation();
      case ConversationProviderCode.queryConversation:
        return await queryConversation();
      case ConversationProviderCode.queryAllConversation:
        return await queryAllConversation();
      default:
        print('conversation provider provide error');
    }
  }

  @override
  void setEntity(entity) {
    _providerEntity = entity;
  }

  @override
  Map<String, List<String>> get tables => const <String, List<String>>{
        'conversation': ['username', 'alias', 'overview', 'timestamp'],
      };

  @override
  Future addConversation() async {
    if (await queryConversation() != ConversationEntity.emptyConversationEntity)
      return false;
    else {
      try {
        await db.insert('conversation', entity.content.toMap());
        return true;
      } catch (e) {
        return false;
      }
    }
  }

  @override
  Future deleteConversation() async {
    final result = await db.delete('conversation',
        where: 'username = ?', whereArgs: [entity.content.username]);
    assert(result <= 1,
        'Well, there should not exsit more than one conversation with username: ${entity.content.username}');
    return result == 1;
  }

  @override
  Future queryAllConversation() async {
     final result = await db.query(
      'conversation',
      columns: tables['conversation'],
    );
    if (result.isEmpty)
      return [];
    else
      return result.map((r) => ConversationEntity.fromMap(r)).toList();
  }

  @override
  Future queryConversation() async {
    ConversationEntity conversationEntity = entity.content;
    final result = await db.query('conversation',
        columns: tables['conversation'],
        where: 'username = ?',
        whereArgs: [conversationEntity.username]);
    assert(result.length <= 1,
        'Well, there should not exsit more than one conversation with username: ${entity.content.username}');
    if (result.isEmpty)
      return ConversationEntity.emptyConversationEntity;
    else
      return ConversationEntity.fromMap(result[0]);
  }

  @override
  Future updateConversation() async {
    final result = await db.update('conversation', entity.content.toMap(),
        where: 'username = ?', whereArgs: [entity.content.username]);
    assert(result <= 1,
        'Well, there should not exsit more than one conversation with username: ${entity.content.username}');
    return result == 1;
  }
}
