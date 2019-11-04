import 'dart:io';

import 'package:free_chat/entity/backend/handle_result_entity.dart';

abstract class IProtocolService {
  Future<WebSocket> init();
  send();
  Future<HandleResultEntity> handle(WebSocket webSocket);
  Future<void> dispose({bool reserveWs = true});
  get entity;
  void setEntity(entity);
}
