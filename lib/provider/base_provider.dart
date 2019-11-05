import 'package:sqflite/sqflite.dart';

abstract class IProvider {
  get entity;
  void setEntity(entity);
  Future<bool> init();
  Future provide();
  Future close();
}

abstract class BaseProvider {
  Database db;
  String get dbName;
  String get ownerName;
  Map<String, List<String>> get tables;
}
