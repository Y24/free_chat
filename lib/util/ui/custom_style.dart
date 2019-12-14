import 'package:flutter/material.dart';
import 'package:free_chat/entity/enums.dart';
import 'package:free_chat/provider/base_provider.dart';
import 'package:free_chat/provider/configuration_provider.dart';
import 'package:free_chat/provider/entity/provider_code.dart';
import 'package:free_chat/provider/entity/provider_entity.dart';
import 'package:free_chat/util/function_pool.dart';
import 'package:provider/provider.dart';

class CustomStyle extends StatefulWidget {
  final Widget child;
  final String username;
  CustomStyle({this.username, this.child});
  @override
  CustomStyleState createState() => CustomStyleState();
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
  bool _isFetching = true;
  IProvider _provider;
  String languageCode;
  ThemeDataCode themeDataCode;
  Color primaryColor;
  @override
  void initState() {
    super.initState();
    _provider = ConfigurationProvider(username: widget.username)
      ..init().then((result) async {
        if (result) {
          languageCode = await _getLanguageCode();
          themeDataCode = await _getThemeDataCode();
          primaryColor = await _getPrimaryColor();
          _isFetching = false;
        }
      });
  }

  Future<String> _getLanguageCode() async {
    _provider.setEntity(
        ProviderEntity(code: ConfigurationProviderCode.queryLanguage));
    return await _provider.provide();
  }

  Future<ThemeDataCode> _getThemeDataCode() async {
    _provider
        .setEntity(ProviderEntity(code: ConfigurationProviderCode.queryTheme));
    return FunctionPool.getThemeDataCodeFromStr(await _provider.provide());
  }

  Future<Color> _getPrimaryColor() async {
    _provider.setEntity(
        ProviderEntity(code: ConfigurationProviderCode.queryPrimaryColor));
    return FunctionPool.getPrimaryColorFromStr(await _provider.provide());
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final locale = Localizations.localeOf(context);
    if (!_isFetching)
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<LanguageState>.value(
            value: LanguageState(
                FunctionPool.getLanguageFromCode(languageCode, locale: locale)),
          ),
          ChangeNotifierProvider<CustomThemeDataState>.value(
            value: CustomThemeDataState(FunctionPool.getThemeDataFromCode(
              themeDataCode,
              brightness: brightness,
              primaryColor: primaryColor,
            )),
          ),
        ],
        child: widget.child,
      );
    else
      return Scaffold(body: Container());
  }
}
