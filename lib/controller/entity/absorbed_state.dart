import 'package:flutter/material.dart';

/// An [ExposedState] has a method named [update] to expose the [protected] method [State.setState].
/// 
/// The [update] method is expected to use just a light-weight delegation of the mothod [State.setState] in [State] and can be overrided as follows:
/// ```dart
/// void update(VoidCallback fn) {
///    setState(fn);
///  }
/// ```
/// see also:
/// * [State.setState], where is pretty similar with everybody.
@optionalTypeArgs
abstract class ExposedState<T extends StatefulWidget> extends State<T> {
  ///
  void update(VoidCallback fn);
}
