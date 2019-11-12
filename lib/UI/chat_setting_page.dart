import 'package:flutter/material.dart';

class ChatSettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: new _ChatSettingListView(),
    );
  }
}

class _ChatSettingListView extends StatefulWidget {
  const _ChatSettingListView({
    Key key,
  }) : super(key: key);
  @override
  __ChatSettingListViewState createState() => __ChatSettingListViewState();
}

class __ChatSettingListViewState extends State<_ChatSettingListView> {
  bool _opened = false;
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListView(
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
          child: Center(child: Text('限定时间（单位：秒,要求：>10）')),
        ),
        TextField(
          controller: _controller,
          enabled: _opened,
          keyboardType: TextInputType.number,
        ),
        SizedBox(
          height: 14,
        ),
        RaisedButton(
          child: Text('提交'),
          onPressed: () {
            if (_opened) {
              try {
                final parse = int.parse(_controller.text ?? '0');
                if (parse < 10) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text('时间间隔应该大于10'),
                    backgroundColor: Colors.red,
                  ));
                  return;
                }
                Navigator.of(context).pop(!_opened ? 0 : parse);
              } catch (e) {
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('请输入合法正整数'),
                  backgroundColor: Colors.red,
                ));
              }
            }
          },
        ),
      ],
    );
  }
}
