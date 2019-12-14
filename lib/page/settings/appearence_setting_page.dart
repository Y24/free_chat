import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:free_chat/entity/enums.dart';
import 'package:free_chat/provider/mixin/configuration_mixin.dart';

class AppearenceSettingPage extends StatefulWidget {
  final String username;
  AppearenceSettingPage(this.username);

  @override
  _AppearenceSettingPageState createState() => _AppearenceSettingPageState();
}

class _AppearenceSettingPageState extends State<AppearenceSettingPage>
    with ConfigurationMixin {
  bool _fetched = false;
  Color _primaryColor;
  String _languageCode;
  ThemeDataCode _themeDataCode;
  @override
  void initState() {
    init(widget.username).then((result) async {
      if (result) {
        _languageCode = await getLanguageCode();
        _themeDataCode = await getThemeDataCode();
        _primaryColor = await getPrimaryColor();
        _fetched = true;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.separated(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          itemCount: 4,
          separatorBuilder: (context, index) {
            if (index == 0)
              return SizedBox(
                height: 14,
              );
            return Divider(
              color: Colors.grey,
            );
          },
          itemBuilder: (context, index) {
            if (index == 0)
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Appearence',
                  style: Theme.of(context).textTheme.body2,
                ),
              );

            if (index == 1)
              return ListTile(
                title: Text(
                  'Language',
                  style: Theme.of(context).textTheme.body1,
                ),
                subtitle: Text(
                  'English',
                  style: Theme.of(context).textTheme.caption,
                ),
                onTap: () {
                  showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => SimpleDialog(
                            title: Text('Select your language'),
                            children: <Widget>[
                              ListTile(
                                leading: Icon(
                                  Icons.radio_button_checked,
                                  color: Colors.blue,
                                ),
                                title: Text('Auto'),
                                onTap: () {
                                  Navigator.pop(context, 'Auto');
                                },
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.radio_button_unchecked,
                                  color: Colors.blue,
                                ),
                                title: Text('English'),
                                onTap: () {
                                  Navigator.pop(context, 'English');
                                },
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.radio_button_unchecked,
                                  color: Colors.blue,
                                ),
                                title: Text('Chinese'),
                                onTap: () {
                                  Navigator.pop(context, 'Chinese');
                                },
                              ),
                            ],
                          ));
                },
              );
            if (index == 2)
              return ListTile(
                title: Text(
                  'Theme',
                  style: Theme.of(context).textTheme.body1,
                ),
                subtitle: Text(
                  'Light',
                  style: Theme.of(context).textTheme.caption,
                ),
                onTap: () {
                  showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => SimpleDialog(
                            title: Text('Select your theme'),
                            children: <Widget>[
                              ListTile(
                                leading: Icon(
                                  Icons.radio_button_checked,
                                  color: Colors.blue,
                                ),
                                title: Text('Auto'),
                                onTap: () {
                                  Navigator.pop(context, 'Auto');
                                },
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.radio_button_unchecked,
                                  color: Colors.blue,
                                ),
                                title: Text('Light'),
                                onTap: () {
                                  Navigator.pop(context, 'Light');
                                },
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.radio_button_unchecked,
                                  color: Colors.blue,
                                ),
                                title: Text('Dark'),
                                onTap: () {
                                  Navigator.pop(context, 'Dark');
                                },
                              ),
                            ],
                          ));
                },
              );
            if (index == 3)
              return ListTile(
                title: Text(
                  'Primary color',
                  style: Theme.of(context).textTheme.body1,
                ),
                subtitle: Text(
                  'Blue',
                  style: Theme.of(context).textTheme.caption,
                ),
                trailing: Material(
                  type: MaterialType.circle,
                  color: Colors.blue,
                  child: SizedBox(
                    height: 40,
                    width: 40,
                  ),
                ),
                onTap: () {
                  showDialog<Color>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: Text('Select a color'),
                      content: BlockPicker(
                        availableColors: const [
                          Colors.amber,
                          Colors.blue,
                          Colors.brown,
                          Colors.cyan,
                          Colors.green,
                          Colors.lime,
                          Colors.orange,
                          Colors.pink,
                          Colors.purple,
                          Colors.red,
                          Colors.teal,
                          Colors.yellow,
                        ],
                        pickerColor: Colors.blue,
                        onColorChanged: (color) {
                          Navigator.pop(context, color);
                        },
                      ),
                    ),
                  );
                },
              );
          }),
    );
  }
}
