import 'package:flutter/material.dart';

class CustomWillPopScope extends StatefulWidget {
  final Widget child;
  CustomWillPopScope({this.child});
  @override
  _CustomWillPopScopeState createState() => _CustomWillPopScopeState();
}

class _CustomWillPopScopeState extends State<CustomWillPopScope> {
  bool _checkBoxValue = true;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print('On will Pop');
        return showDialog(
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, state) => AlertDialog(
                      title: const Text('Are you sure?'),
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Keep background task',
                          ),
                          Checkbox(
                            value: _checkBoxValue,
                            onChanged: (bool value) {
                              print('onChanged: $value');
                              state(() {
                                _checkBoxValue = value;
                              });
                            },
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(false),
                          child: roundedButton(
                              "No", Colors.blue, const Color(0xFFFFFFFF)),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(true),
                          child: roundedButton(
                              " Yes ", Colors.blue, const Color(0xFFFFFFFF)),
                        ),
                      ],
                    ),
                  );
                }) ??
            false;
      },
      child: widget.child,
    );
  }
}

Widget roundedButton(String buttonLabel, Color bgColor, Color textColor) {
  var loginBtn = new Container(
    padding: EdgeInsets.all(5.0),
    alignment: FractionalOffset.center,
    decoration: new BoxDecoration(
      color: bgColor,
      borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.blue[900],
          offset: Offset(1.0, 6.0),
          blurRadius: 0.001,
        ),
      ],
    ),
    child: Text(
      buttonLabel,
      style: new TextStyle(
          color: textColor, fontSize: 20.0, fontWeight: FontWeight.bold),
    ),
  );
  return loginBtn;
}
