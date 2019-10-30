import 'dart:io';

import 'package:flutter/material.dart';
import 'package:free_chat/entity/backend/protocol/chat_protocol.dart';
import 'package:free_chat/services/chat_service.dart';

class Client extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'WebSocket Demo';
    return MaterialApp(
      title: title,
      home: WebSocketDemo(
        title: title,
      ),
    );
  }
}

class WebSocketDemo extends StatefulWidget {
  final String title;
  WebSocketDemo({Key key, @required this.title}) : super(key: key);
  @override
  _WebSocketDemoState createState() => new _WebSocketDemoState();
}

class _WebSocketDemoState extends State<WebSocketDemo> {
  TextEditingController _controller = new TextEditingController();
  ChatService chatService = ChatService(
    userId: 1234,
    isGroupChat: false,
    targetId: 5678,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: chatService.initWebSocket(),
      builder: (context, snapshot) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: snapshot.connectionState == ConnectionState.done
            ? Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('${snapshot.data}'),
                    Text('The socket is : ${chatService.stream}'),
                    RaisedButton(
                      onPressed: () {
                        setState(() {
                          chatService.initWebSocket().then((value) {
                            print('result: $value');
                          });
                        });
                      },
                      child: Text('Connect'),
                    ),
                    Form(
                      child: TextFormField(
                        controller: _controller,
                        decoration:
                            InputDecoration(labelText: 'Send a message'),
                      ),
                    ),
                    StreamBuilder(
                      stream: chatService.stream,
                      builder: (context, snapshot) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child:
                              Text(snapshot.hasData ? '${snapshot.data}' : ''),
                        );
                      },
                    )
                  ],
                ),
              )
            : CircularProgressIndicator(),
        floatingActionButton: FloatingActionButton(
          onPressed: _sendMessage,
          tooltip: 'Send message',
          child: Icon(Icons.send),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      print('Sending data: ${_controller.text}');
      chatService.newSend(
          id: 1234, content: _controller.text, timestamp: DateTime.now());
    }
  }

  @override
  void dispose() {
    chatService.close();
    super.dispose();
  }
}
