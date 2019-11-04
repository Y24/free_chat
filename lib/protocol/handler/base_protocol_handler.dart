import 'dart:io';

import 'package:free_chat/entity/backend/handle_result_entity.dart';
import 'package:sqflite/sqflite.dart';

abstract class IProtocolHandler {
  Future<bool> init();
  Future<HandleResultEntity> handle(WebSocket webSocket);
  Future<void> dispose();
  get entity;
  void setEntity(entity);
}

abstract class BaseProtocolHandler {
  static final dbPathPrefix = 'free_chat';
  Database _db;
  bool _connected = false;
  String get dbName;
  bool get connected => _connected;
  Future<void> cleanUp() async {
    await _db?.close();
    _db = null;
    _connected = false;
  }

  Future<bool> setUp() async {
    if (_connected && _db != null) return true;
    await cleanUp();
    try {
      _db = await openDatabase('$dbPathPrefix/$dbName.db',
          version: 1, onCreate: (db, version) {});
      _connected = true;
      return true;
    } catch (e) {
      print('Error when open db: $e');
      return false;
    }
  }

  Future<void> close() async {
    await cleanUp();
  }
}
