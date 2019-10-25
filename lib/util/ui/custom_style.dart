import 'package:flutter/material.dart';
import 'package:free_chat/configuration/configuration.dart';
import 'package:free_chat/entity/enums.dart';
import 'package:free_chat/util/function_pool.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomStyle extends StatefulWidget {
  final Widget child;
  CustomStyle({this.child});
  @override
  CustomStyleState createState() => CustomStyleState(child: child);
}

class LanguageState extends ChangeNotifier {
  Language _language;
  Language get language => _language;
  LanguageState(Language language) {
    _language = language;
  }
  void switchTo({Language newLanguage}) {
    _language = newLanguage;
    notifyListeners();
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final LanguageState typedOther = other;
    return language == typedOther.language;
  }

  @override
  int get hashCode => language.hashCode;
}

class CustomThemeDataState extends ChangeNotifier {
  ThemeData _themeData;
  ThemeData get themeData => _themeData;
  CustomThemeDataState(ThemeData themeData) {
    _themeData = themeData;
  }
  void switchTo({ThemeData themeData}) {
    _themeData = themeData;
    notifyListeners();
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final CustomThemeDataState typedOther = other;
    return themeData == typedOther.themeData;
  }

  @override
  int get hashCode => themeData.hashCode;
}

class CustomStyleState extends State<CustomStyle> {
  final Widget child;
  bool _isFetching = true;
  Language language = Configuration.defLanguage;
  ThemeDataCode themeDataCode = Configuration.defThemeDataCode;
  CustomStyleState({this.child});
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        language = FunctionPool.getLanguageFromCode(
                code: FunctionPool.getCustomStyle(prefs, target: 'language')) ??
            Configuration.defLanguage;
        themeDataCode = FunctionPool.getThemeDataCodeFromStr(
                FunctionPool.getCustomStyle(prefs, target: 'themeData')) ??
            Configuration.defThemeDataCode;
        _isFetching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isFetching)
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<LanguageState>.value(
            value: LanguageState(language),
          ),
          ChangeNotifierProvider<CustomThemeDataState>.value(
            value: CustomThemeDataState(
                FunctionPool.getThemeData(themeDataCode: themeDataCode)),
          ),
        ],
        child: child,
      );
    else
      return MaterialApp(home: Scaffold(body: Container()));
  }
}
