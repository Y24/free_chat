import 'dart:async';

import 'dart:io';

typedef OnDataCallBack = void Function(dynamic);
typedef VoidCallback = void Function();

abstract class IProtocolSender {
  Future<WebSocket> init();
  send();
  Future<void> dispose();
  get entity;
  void setEntity(entity);
}

abstract class BaseProtocolSender {
  static final String schema = 'wss';
  static final domainName = 'y24.org.cn';
  static final port = 2424;
  String get urlPrefix;
  WebSocket webSocket;
  bool _connected = false;

  bool get connected => _connected;
  Future<void> clean() async {
    await webSocket?.close();
    webSocket = null;
    _connected = false;
  }

  Future<WebSocket> setUp() async {
    print('setUp: _connected: $_connected ,webSocket: $webSocket');
    if (_connected && webSocket != null) return webSocket;
    await clean();
    try {
      print('$schema://$domainName:$port/$urlPrefix');
      webSocket =
          await WebSocket.connect('$schema://$domainName:$port/$urlPrefix');
      _connected = true;
      print('After setUp: _connected: $_connected ,webSocket: $webSocket');
      return webSocket;
    } catch (e) {
      return null;
    }
  }

  Future<void> close() async {
    await clean();
  }
}
