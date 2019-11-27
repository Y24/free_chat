import 'package:flutter/material.dart';
import 'package:free_chat/controller/entity/absorbed_state.dart';

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
