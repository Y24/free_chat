///
/// Powered by FilledStacks
/// ![](https://github.com/FilledStacks/flutter-tutorials/blob/master/022-lifecycle-manager/lib/lifecycle_manager.dart)
///

import 'package:flutter/material.dart';

class LifecycleManager extends StatefulWidget {
  final Widget child;
  LifecycleManager({Key key, this.child}) : super(key: key);

  @override
  _LifecycleManagerState createState() => _LifecycleManagerState();
}

class _LifecycleManagerState extends State<LifecycleManager>
    with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print(state.toString());
  }
}
