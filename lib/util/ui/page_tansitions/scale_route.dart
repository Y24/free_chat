/// 
/// Powered by divyanshub024
/// ![](https://github.com/divyanshub024/Flutter-page-route-transition)
/// 
import 'package:flutter/material.dart';

class ScaleRoute extends PageRouteBuilder {
  final Widget page;
  ScaleRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child) =>
              ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.fastOutSlowIn,
              ),
            ),
            child: child,
          ),
        );
}
