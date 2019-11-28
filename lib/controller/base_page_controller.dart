import 'package:flutter/material.dart';
import 'package:free_chat/controller/entity/exposed_state.dart';

/// [BasePageController] is the only abstract super class of every concrete [PageController].
///
/// An instance of some concrete [PageController] can be the controller of the corrosponding [Page] in which way that we can separate [Model] from [View].
///
/// See also:
///
/// * MVC Pattern
/// * AccountPageController
/// * ChatPageController
abstract class BasePageController {
  ExposedState _state;
  ExposedState get state => _state;
  String get path;
  @mustCallSuper
  void init({ExposedState state}) {
    _state = state;
  }

  void dispose();
}
