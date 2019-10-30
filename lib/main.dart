import 'package:flutter/material.dart';
import 'package:free_chat/UI/chat_page.dart';
import 'package:free_chat/UI/websocket_demo.dart';
import 'package:free_chat/util/ui/start_page.dart';

void main() => runApp(MaterialApp(
      title: 'WebSocket',
      home: WebSocketDemo(
        title: 'WebSockt',
      ),
    ));
