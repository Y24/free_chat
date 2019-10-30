import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:free_chat/entity/backend/protocol/chat_protocol.dart';
import 'package:free_chat/entity/enums.dart';
import 'package:free_chat/services/chat_service.dart';

main() {
  testWidgets('Chat protocol test', (WidgetTester tester) async {
    HeadEntity head = HeadEntity(
      id: 2424,
      code: ChatProtocolCode.newSend,
      timestamp: DateTime.now(),
      fromId: 1234,
      toId: 5678,
      isGroupChat: false,
    );
    BodyEntity body = BodyEntity(
      message: Message(
        id: 1357,
        content: 'ContentOfMessageOfBody',
      ),
    );
    ProtocolEntity protocolEntity = ProtocolEntity(head: head, body: body);
    ChatService chatService = ChatService(
      userId: 1234,
      isGroupChat: false,
      targetId: 5678,
    );
    final reslut = await chatService.initWebSocket();
    if (reslut) {
      print('init webSocket successfully.');
      chatService.stream.listen((respose) {
        print('Recieved: $respose');
      });
      chatService.newSend(
        id: 1234,
        content: 'Hello, yue!',
        timestamp: DateTime.now(),
      );
      Future.delayed(Duration(seconds: 14), () {
        chatService.close();
      });
    } else {
      print('Connnection failed');
    }
  });
}
