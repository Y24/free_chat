import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:free_chat/configuration/configuration.dart';
import 'package:free_chat/entity/enums.dart';
import 'package:free_chat/entity/history_entity.dart';
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

  static bool shouldShowTimeStamp(final List<HistoryEntity> list, int index) {
    assert(index < list.length && index >= 0);
    if (index == list.length - 1) return false;
    //  print(list[index].timestamp.difference(list[index + 1].timestamp).abs().inMinutes);
    return list[index]
            .timestamp
            .difference(list[index + 1].timestamp)
            .abs()
            .inMinutes >
        1;
  }

  static final Map<String, MessageSendStatus> _strToMSS = {
    'processing': MessageSendStatus.processing,
    'failture': MessageSendStatus.failture,
    'success': MessageSendStatus.success,
  };
  static MessageSendStatus getMessageSendStatusByStr(String s) => _strToMSS[s];
  static String getStrByMessageSendStatus(MessageSendStatus status) =>
      _strToMSS.map((s, status) => MapEntry(status, s))[status];
  static final _supportedProtocolCodes = [
    ChatProtocolCode,
    AccountProtocolCode,
    bool,
  ];
  static final Map<ChatProtocolCode, String> _cPCToStr = {
    ChatProtocolCode.newSend: 'newSend',
    ChatProtocolCode.reSend: 'reSend',
    ChatProtocolCode.accept: 'accept',
    ChatProtocolCode.reject: 'reject',
  };
  static String getStrByProtocolCode(dynamic code) {
    assert(_supportedProtocolCodes.any((type) => code.runtimeType == type),
        'Well,here is a bug to be fixed.');
    if (code is bool) return code ? 'true' : 'false';
    if (code is ChatProtocolCode) return getStrByChatProtocolCode(code);
    if (code is AccountProtocolCode) return getStrByAccountProtocolCode(code);
    assert(false, 'You hould not be here in the normal case.');
    return '';
  }

  static final Map<bool, String> _boolToStr = {
    true: 'true',
    false: 'false',
  };
  static getProtocolCodeByStr(String s) {
    if (_boolToStr.containsValue(s)) return s == 'true';
    if (_cPCToStr.containsValue(s)) return getChatProtocolCodeByStr(s);
    if (_apcToStr.containsValue(s)) return getAccountProtocolCodeByStr(s);
    assert(false, 'You hould not be here in the normal case.');
    return '';
  }

  static ChatProtocolCode getChatProtocolCodeByStr(String s) =>
      _cPCToStr.map((code, s) => MapEntry(s, code))[s];
  static String getStrByChatProtocolCode(ChatProtocolCode code) =>
      _cPCToStr[code];
  static final Map<AccountProtocolCode, String> _apcToStr = {
    AccountProtocolCode.login: 'login',
    AccountProtocolCode.logout: 'logout',
    AccountProtocolCode.register: 'register',
    AccountProtocolCode.cleanUp: 'cleanUp',
  };
  static AccountProtocolCode getAccountProtocolCodeByStr(String s) =>
      _apcToStr.map((code, s) => MapEntry(s, code))[s];
  static String getStrByAccountProtocolCode(AccountProtocolCode code) =>
      _apcToStr[code];
}
