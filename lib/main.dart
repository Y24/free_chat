import 'package:flutter/material.dart';
import 'package:free_chat/provider/test/configuration_test.dart';
import 'package:free_chat/util/ui/start_page.dart';

// void main() => runApp(StartPage());
void main() => runApp(MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark().copyWith(
          primaryColor: Colors.green,
          buttonTheme: ButtonThemeData().copyWith(
            buttonColor: Colors.green,
          ),
          snackBarTheme: SnackBarThemeData().copyWith(
              backgroundColor: Colors.black,
              contentTextStyle: TextStyle().copyWith(
                color: Colors.white,
              ))),
      theme: ThemeData.light().copyWith(),
      home: ConfigurationTest(username: 'y'),
    ));
