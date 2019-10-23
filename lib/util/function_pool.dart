import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:free_chat/configuration/configuration.dart';
import 'package:free_chat/entity/enums.dart';
import 'package:free_chat/util/ui/clip_oval_logo.dart';
import 'package:free_chat/util/ui/custom_style.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class FunctionPool {
  static final _languages = {
    'en': Language.en,
    'zh': Language.zh,
  };
  static Language getLanguageFromLocale({final Locale locale}) {
    return _languages[locale.languageCode];
  }

  static Language getLanguageFromCode({final String code}) {
    return _languages[code];
  }

  static String getCodeFromLanguage({final Language language}) {
    return _languages
        .map((String s, Language language) => MapEntry(language, s))[language];
  }

  static final _themeDatas = {
    ThemeDataCode.defLight: ThemeData.light(),
    ThemeDataCode.defDark: ThemeData.dark(),
  };
  static ThemeData getThemeData({ThemeDataCode themeDataCode}) {
    return _themeDatas[themeDataCode];
  }

  static String getStringRes({@required final key, @required final language}) {
    return Configuration.strPool[key][language];
  }

  static getAccountInfo(SharedPreferences preferences, {String target}) {
    return preferences.get(Configuration.sharedPrefKeys['account'][target]);
  }

  static addAccountInfo(SharedPreferences preferences,
      {String target, final value}) async {
    if (value is int) {
      print('$value: int');
      await preferences.setInt(
          Configuration.sharedPrefKeys['account'][target], value);
      return;
    }
    if (value is bool) {
      print('$value: bool');
      await preferences.setBool(
          Configuration.sharedPrefKeys['account'][target], value);
      return;
    }
    if (value is double) {
      print('$value: double');
      await preferences.setDouble(
          Configuration.sharedPrefKeys['account'][target], value);
      return;
    }
    if (value is String) {
      print('$value: String');
      await preferences.setString(
          Configuration.sharedPrefKeys['account'][target], value);
      return;
    }
    if (value is List<String>) {
      print('$value: List<String>');
      await preferences.setStringList(
          Configuration.sharedPrefKeys['account'][target], value);
      return;
    }
    print('No suit type fo $value with runtimeType ${value.runtimeType}!');
  }

  static getCustomStyle(SharedPreferences preferences, {String target}) {
    return preferences.get(Configuration.sharedPrefKeys['customStyle'][target]);
  }

  static Future<void> addCustomStyle(SharedPreferences preferences,
      {String target, String value}) async {
    print('set target:$target ,value:$value');
    await preferences.setString(
        Configuration.sharedPrefKeys['customStyle'][target], value);
  }

  static void showCustomAboutDialog({
    @required BuildContext context,
    List<Widget> children,
  }) {
    assert(context != null);
    final languageState = Provider.of<LanguageState>(context);
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AboutDialog(
          applicationName: Configuration.appName[languageState.language],
          applicationVersion: Configuration.appVersion,
          applicationIcon: const ClipOvalLogo(),
          applicationLegalese:
              Configuration.appLegalese[languageState.language],
          children: children,
        );
      },
    );
  }

  static void showCustomLicensePage({
    @required BuildContext context,
  }) {
    assert(context != null);
    final languageState = Provider.of<LanguageState>(context);
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => LicensePage(
          applicationName: Configuration.appName[languageState.language],
          applicationVersion: Configuration.appVersion,
          applicationIcon: const ClipOvalLogo(),
          applicationLegalese:
              Configuration.appLegalese[languageState.language],
        ),
      ),
    );
  }

  static ThemeDataCode getThemeDataCodeFromStr(String themeDataStr) {
    switch (themeDataStr) {
      case 'defLight':
        return ThemeDataCode.defLight;
      case 'defDark':
        return ThemeDataCode.defDark;
      default:
        return ThemeDataCode.defLight;
    }
  }
}
