import 'dart:io';

import 'package:flutter/material.dart';

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
  WebSocket webSocket;
  Future<bool> initWebSocket() async {
    try {
      print('begin connecting');
      // webSocket = await WebSocket.connect('ws://127.0.0.1:2424/');
      webSocket = await WebSocket.connect('ws://y24.org.cn:2424');
      webSocket.add('hello');
      print('connect WebSocket: ${webSocket.runtimeType}');
    } catch (e) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initWebSocket(),
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
                    Text('The socket is : $webSocket'),
                    RaisedButton(
                      onPressed: () {
                        setState(() {
                          initWebSocket().then((value) {
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
                      stream: webSocket,
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
      webSocket.add(_controller.text);
    }
  }

  @override
  void dispose() {
    webSocket.close();
    super.dispose();
  }
}
