import 'package:free_chat/entity/enums.dart';

class WelcomePageResource {
  final String imageName;
  final String introTitle;
  final String introContent;
  const WelcomePageResource(
      {this.imageName, this.introTitle, this.introContent});
}

abstract class Configuration {
  static final maxConnectionTryTimes = 2;
  static final sharedPrefKeys = {
    'account': {
      'loginStatus': 'LoginStatus',
      'loginAccountUsername': 'LoginAccountUsername',
    },
  };
  static final appName = {
    Language.en: 'free chat',
    Language.zh: '轻聊',
  };
  static final appLegalese = {
    Language.en: 'Legalese',
    Language.zh: '服务条款',
  };
  static final appVersion = 'preRelease 1.0.0 alpha';

  static final connectionMaxSeconds = 7;
  static final strPool = {
    'registerStr': {
      Language.en: 'Register',
      Language.zh: '注册',
    },
    'loginStr': {
      Language.en: 'Login',
      Language.zh: '登录',
    },
    'usernameStr': {
      Language.en: 'Username',
      Language.zh: '用户名',
    },
    'passwordStr': {
      Language.en: 'Password',
      Language.zh: '密码',
    },
    'cancelStr': {
      Language.en: 'Cancel',
      Language.zh: '取消',
    },
    'forgotPasswordStr': {
      Language.en: 'Forget password?',
      Language.zh: '忘记密码？',
    },
    'usernameValidatorEmptyStr': {
      Language.en: 'Username cannot be empty!',
      Language.zh: '用户名不能为空！',
    },
    'usernameInvalidStr': {
      Language.en: 'Invalid username, please try another.',
      Language.zh: '用户名不可用，请重试',
    },
    'passwordValidatorEmptyStr': {
      Language.en: 'Password cannot be empty!',
      Language.zh: '密码不能为空！',
    },
    'passwordInvalidStr': {
      Language.en: 'Invalid password, try another!',
      Language.zh: '密码不可用，请重试',
    },
    'registerHintStr': {
      Language.en: 'Length: 1-',
      Language.zh: '长度应为：1-',
    },
    'registerSuccessStr': {
      Language.en: 'Register success',
      Language.zh: '注册成功',
    },
    'passwordConfirmHintStr': {
      Language.en: 'Confirm',
      Language.zh: '确认',
    },
    'confirmFailtureStr': {
      Language.en: 'Confirm failture!',
      Language.zh: '确认错误',
    },
    'authenticationFailtureStr': {
      Language.en: 'Authentication failture!',
      Language.zh: '验证失败',
    },
    'serverErrorStr': {
      Language.en: 'Server error!',
      Language.zh: '服务器错误',
    },
    'timeOutStr': {
      Language.en: 'Time out!',
      Language.zh: '超时',
    },
    'unknownErrorStr': {
      Language.en: 'Unknown error!',
      Language.zh: '未知错误',
    },
  };
  static final imageResourcePathPrefix = 'res/images/';
  static final defLanguage = Language.en;
  static ThemeDataCode defThemeDataCode = ThemeDataCode.defLight;
  static final welcomePages = {
    Language.en: [
      WelcomePageResource(
        imageName: '${imageResourcePathPrefix}enjoyLife.jpg',
        introTitle: 'Welcome to Free Chat',
        introContent: 'Chat freely as you wish anytime, anywhere.',
      ),
      WelcomePageResource(
        imageName: '${imageResourcePathPrefix}milk.jpg',
        introTitle: 'Chat with more convinience',
        introContent: 'No worry about security, speeding, and much more.',
      ),
      WelcomePageResource(
        imageName: '${imageResourcePathPrefix}rain.jpg',
        introTitle: 'Explore more features',
        introContent: 'Start it right now for more features!',
      ),
    ],
    Language.zh: [
      WelcomePageResource(
        imageName: '${imageResourcePathPrefix}enjoyLife.jpg',
        introTitle: '欢迎使用轻聊',
        introContent: '无论何时何地，如你所愿，轻松聊天。',
      ),
      WelcomePageResource(
        imageName: '${imageResourcePathPrefix}milk.jpg',
        introTitle: '更方便地聊天',
        introContent: '不必担心聊天时的安全，开销以及更多问题。',
      ),
      WelcomePageResource(
        imageName: '${imageResourcePathPrefix}rain.jpg',
        introTitle: '探索更多特性',
        introContent: '马上轻聊，发现更多有趣功能！',
      ),
    ],
  };
  static final introductionDoneText = {
    Language.en: 'Get start',
    Language.zh: '开始',
  };
  static final languageStrings = {
    Language.en: 'English',
    Language.zh: '中文',
  };
  static final languagesStr = {
    Language.en: 'Language',
    Language.zh: '语言',
  };
}
