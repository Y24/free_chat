/**
 * Author: Damodar Lohani
 * profile: https://github.com/lohanidamodar
  */

import 'package:flutter/material.dart';
import 'package:free_chat/UI/home_page.dart';
import 'package:free_chat/configuration/configuration.dart';
import 'package:free_chat/util/ui/page_tansitions/slide_route.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';

class WelcomePage extends StatelessWidget {
  final username;
  static final String path = 'lib\UI\wlecome.dart';

  final language;
  WelcomePage({this.language, this.username});

  @override
  Widget build(BuildContext context) {
    final pages = [
      ...Configuration.welcomePages[language]
          .map((WelcomePageResource w) => PageViewModel(
                pageColor: Color(0xF6F6F7FF),
                bubbleBackgroundColor: Colors.blue,
                title: Container(),
                body: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Text(w.introTitle),
                    ),
                    Text(
                      w.introContent,
                      style: TextStyle(color: Colors.black54, fontSize: 16.0),
                    ),
                  ],
                ),
                mainImage: Image.asset(
                  w.imageName,
                  width: 285.0,
                  alignment: Alignment.center,
                ),
                textStyle: TextStyle(color: Colors.black),
              )),
    ];
    return Scaffold(
      body: Stack(
        children: <Widget>[
          IntroViewsFlutter(
            pages,
            onTapDoneButton: () {
              Navigator.pushAndRemoveUntil(
                context,
                SlideRightRoute(
                    page: HomePage(
                  username: username,
                )),
                (route) => route==null,
              );
            },
            showSkipButton: false,
            doneText: Text(
              Configuration.introductionDoneText[language],
            ),
            pageButtonsColor: Colors.blue,
            pageButtonTextStyles: TextStyle(
              fontSize: 16.0,
              fontFamily: "Regular",
            ),
          ),
        ],
      ),
    );
  }
}
