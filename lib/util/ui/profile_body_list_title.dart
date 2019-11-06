import 'package:flutter/material.dart';
import 'package:free_chat/entity/enums.dart';
import 'package:free_chat/util/ui/custom_style.dart';
import 'package:provider/provider.dart';

const _leadingPool = <String, IconData>{
  'email': Icons.email,
  'phone': Icons.phone,
  'location': Icons.location_on,
};
String _getString(IconData iconData) =>
    _leadingPool.map((s, i) => MapEntry(i, s))[iconData];

IconData _getIconData(String s) => _leadingPool[s];

const _strPool = {
  'email': {
    Language.en: 'Email',
    Language.zh: '邮箱',
  },
  'phone': {
    Language.en: 'Phone',
    Language.zh: '联系电话',
  },
  'location': {
    Language.en: 'Location',
    Language.zh: '住所',
  },
};

class ProfileBodyListTitle {
  final IconData leading;
  final String title;
  String content;
  ProfileBodyListTitle({this.title, this.content})
      : leading = _getIconData(title);
  factory ProfileBodyListTitle.index(int index) {
    final contents = ['githuby24@gmail.com', '110', 'River QingShui of USETC'];
    return ProfileBodyListTitle(
        title: _leadingPool.keys.toList()[index], content: contents[index]);
  }
  ProfileBodyListTitle.fromJson(Map<String, dynamic> json)
      : assert(json != null),
        leading = _getIconData(json['leading']),
        title = json['title'],
        content = json['content'];
  Map<String, dynamic> toJson() => <String, dynamic>{
        'leading': _getString(leading),
        'title': title,
        'content': content,
      };
  toListItem(BuildContext context) {
    final language = Provider.of<LanguageState>(context).language;
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          leading,
          color: Colors.blue,
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(
          top: 8.0,
          left: 8.0,
        ),
        child: Text(_strPool[title][language]),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(
          top: 8.0,
          left: 8.0,
        ),
        child: Text(content),
      ),
    );
  }
}
