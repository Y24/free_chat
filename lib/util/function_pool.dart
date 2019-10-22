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
  static Language getLanguage({final Locale locale}) {
    return _languages[locale.languageCode];
  }

  static final _themeDatas = {
    ThemeDataCode.defLight: ThemeData.light(),
    ThemeDataCode.defDark: ThemeData.dark(),
  };
  static ThemeData getThemeData({ThemeDataCode themeDataCode}) {
    return _themeDatas[themeDataCode];
  }

  static String getStringRes({final key, final language}) {
    return Configuration.strPool[key][language];
  }

  static getAccountInfo(SharedPreferences preferences, {String target}) {
    return preferences.get(Configuration.sharedPrefKeys['account'][target]);
  }

  static addAccountInfo(SharedPreferences preferences,
      {String target, final value}) {
    if (value is int) {
      print('$value: int');
      preferences.setInt(
          Configuration.sharedPrefKeys['account'][target], value);
      return;
    }
    if (value is bool) {
      print('$value: bool');
      preferences.setBool(
          Configuration.sharedPrefKeys['account'][target], value);
      return;
    }
    if (value is double) {
      print('$value: double');
      preferences.setDouble(
          Configuration.sharedPrefKeys['account'][target], value);
      return;
    }
    if (value is String) {
      print('$value: String');
      preferences.setString(
          Configuration.sharedPrefKeys['account'][target], value);
      return;
    }
    if (value is List<String>) {
      print('$value: List<String>');
      preferences.setStringList(
          Configuration.sharedPrefKeys['account'][target], value);
      return;
    }
    print('No suit type fo $value with runtimeType ${value.runtimeType}!');
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
}
