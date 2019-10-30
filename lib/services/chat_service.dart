import 'package:flutter/cupertino.dart';
import 'package:free_chat/entity/backend/protocol/chat_protocol.dart';

class ChatService {
  final int userId;
  final bool isGroupChat;
  final int targetId;
  final ChatProtocol chatProtocol;
  ChatService({this.userId, this.isGroupChat, this.targetId})
      : chatProtocol = ChatProtocol(
          userId: userId,
          toId: targetId,
          isGroupChat: isGroupChat,
        );
  Future<bool> initWebSocket() async {
    return await chatProtocol.setUpWebSocket('y24.org.cn');
  }

  //Stream<ProtocolEntity> get stream => chatProtocol.stream;
  Stream get stream => chatProtocol.stream;
  void newSend({
    @required int id,
    @required String content,
    @required DateTime timestamp,
  }) {
    chatProtocol.newSend(content: content, timestamp: timestamp, id: id);
  }

  bool close() {
    return chatProtocol.close();
  }
}
