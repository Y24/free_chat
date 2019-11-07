import 'package:flutter/material.dart';

class ChatSettingPage extends StatefulWidget {
  @override
  _ChatSettingPageState createState() => _ChatSettingPageState();
}

class _ChatSettingPageState extends State<ChatSettingPage> {
  bool _opened = false;
  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(
              _opened ? Icons.lock_open : Icons.lock,
              color: _opened ? Colors.blue : Colors.grey,
            ),
            title: Text(
              '阅后即焚: ' + (_opened ? '开启' : '关闭'),
              style: TextStyle(
                color: _opened ? Colors.blue : Colors.grey,
              ),
            ),
            trailing: Checkbox(
              onChanged: (r) {
                print('r: $r');
                setState(() {
                  _opened = r;
                });
              },
              value: _opened,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Text('限定时间（单位：秒）')),
          ),
          TextField(
            controller: _controller,
            enabled: _opened,
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 14,),
          RaisedButton(
            child: Text('提交'),
            onPressed: () {
              Navigator.of(context)
                  .pop(!_opened ? 0 : int.parse(_controller.text ?? '0'));
            },
          ),
        ],
      ),
    );
  }
}
