import 'package:flutter/material.dart';
import 'package:free_chat/controller/account_page_controller.dart';
import 'package:free_chat/controller/entity/exposed_state.dart';
import 'package:free_chat/page/account_recovery.dart';
import 'package:free_chat/configuration/configuration.dart';
import 'package:free_chat/entity/enums.dart';
import 'package:free_chat/protocol/sender/base_protocol_sender.dart';
import 'package:free_chat/util/function_pool.dart';
import 'package:free_chat/util/ui/clip_oval_logo.dart';
import 'package:free_chat/util/ui/custom_style.dart';
import 'package:free_chat/util/ui/page_tansitions/slide_route.dart';
import 'package:free_chat/util/validator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print(Provider.of<LanguageState>(context).language.toString());
    final appTitle =
        Configuration.appName[Provider.of<LanguageState>(context).language];
    print('appTitle: $appTitle');
    return MaterialApp(
      title: appTitle,
      theme: Provider.of<CustomThemeDataState>(context).themeData,
      home: Scaffold(
        body: AccountUI(),
      ),
    );
  }
}

// Create a Form widget.
class AccountUI extends StatefulWidget {
  @override
  AccountUIState createState() {
    return AccountUIState();
  }
}

class AccountUIState extends ExposedState<AccountUI> {
  AccountPageController pageController = AccountPageController();
  @override
  void initState() {
    super.initState();
    pageController.init(state: this);
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void update(VoidCallback fn) {
    setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    if (!pageController.providerInited)
      return Center(child: CircularProgressIndicator());
    //final themeState = Provider.of<CustomThemeDataState>(context);
    final languageState = Provider.of<LanguageState>(context);
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                color: Colors.grey[200],
              ),
            ),
          ],
        ),
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 24,
                    top: 24,
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: Colors.blue,
                    ),
                    child: DropdownButton<Language>(
                      value: languageState.language,
                      icon: Icon(
                        Icons.language,
                        color: Colors.white,
                      ),
                      items: Configuration.languageStrings.entries
                          .map((mapEntry) => DropdownMenuItem(
                                value: mapEntry.key,
                                child: Text(
                                  mapEntry.value,
                                  style: TextStyle(color: Colors.grey[100]),
                                ),
                              ))
                          .toList(),
                      hint: Text(
                          Configuration.languagesStr[languageState.language]),
                      onChanged: (newLanguage) {
                        if (newLanguage != languageState.language) {
                          SharedPreferences.getInstance().then((prefs) {
                            FunctionPool.addCustomStyle(prefs,
                                target: 'language',
                                value: FunctionPool.getCodeFromLanguage(
                                    language: newLanguage));
                          });
                          setState(() {
                            languageState.switchTo(newLanguage: newLanguage);
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              ClipOvalLogo(),
              buildSwitchRow(language: languageState.language),
              Container(
                margin: const EdgeInsets.only(left: 24, right: 24, bottom: 14),
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.all(
                    const Radius.circular(8.0),
                  ),
                ),
                child: AnimatedSwitcher(
                  child: pageController.inLoginPage
                      ? buildLoginForm(context,
                          language: languageState.language)
                      : buildRegisterForm(context,
                          language: languageState.language),
                  duration: const Duration(milliseconds: 400),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Form buildRegisterForm(BuildContext context, {Language language}) {
    return Form(
      key: pageController.registerFormKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Text(
              FunctionPool.getStringRes(
                key: 'registerStr',
                language: language,
              ),
              style: TextStyle(
                shadows: [
                  Shadow(
                    color: Colors.blue[300],
                    offset: const Offset(4, 4),
                    blurRadius: 8,
                  ),
                ],
                fontSize: 40,
                color: Colors.blue,
              ),
            ),
          ),
          TextFormField(
            onChanged: (value) {
              pageController.registerUsername = value;
            },
            onFieldSubmitted: (_) {
              FocusScope.of(context)
                  .requestFocus(pageController.registerPasswordFocusNode);
            },
            style: TextStyle(
              color: Colors.blue,
              fontSize: 20,
            ),
            decoration: InputDecoration(
              filled: true,
              labelText: FunctionPool.getStringRes(
                key: 'usernameStr',
                language: language,
              ),
              hintText: FunctionPool.getStringRes(
                      key: 'registerHintStr', language: language) +
                  '${Validator.usernameMaxLength}',
              icon: Icon(
                Icons.person,
                size: 30,
              ),
              border: OutlineInputBorder(),
            ),
            validator: (_) {
              if (pageController.registerUsername.isEmpty) {
                return FunctionPool.getStringRes(
                  key: 'usernameValidatorEmptyStr',
                  language: language,
                );
              }
              if (!Validator.validateUsername(
                  pageController.registerUsername)) {
                return FunctionPool.getStringRes(
                  key: 'usernameInvalidStr',
                  language: language,
                );
              }
              return null;
            },
          ),
          SizedBox(
            height: 24,
          ),
          TextFormField(
            focusNode: pageController.registerPasswordFocusNode,
            onChanged: (value) {
              pageController.registerPassword = value;
            },
            onFieldSubmitted: (value) {
              FocusScope.of(context)
                  .requestFocus(pageController.registerPasswordRepeatFocusNode);
            },
            validator: (_) {
              if (pageController.registerPassword.isEmpty) {
                return FunctionPool.getStringRes(
                  key: 'passwordValidatorEmptyStr',
                  language: language,
                );
              }
              if (!Validator.validatePassword(
                  pageController.registerPassword)) {
                return FunctionPool.getStringRes(
                  key: 'passwordInvalidStr',
                  language: language,
                );
              }
              return null;
            },
            style: TextStyle(
              color: Colors.blue,
              fontSize: 20,
            ),
            decoration: InputDecoration(
              filled: true,
              labelText: FunctionPool.getStringRes(
                key: 'passwordStr',
                language: language,
              ),
              hintText: FunctionPool.getStringRes(
                      key: 'registerHintStr', language: language) +
                  '${Validator.passwordMaxLength}',
              icon: Icon(
                Icons.lock,
                size: 30,
              ),
              border: OutlineInputBorder(),
              suffixIcon: GestureDetector(
                child: Icon(pageController.hideRegisterPassword
                    ? Icons.visibility
                    : Icons.visibility_off),
                onTap: () {
                  setState(() {
                    pageController.hideRegisterPassword =
                        !pageController.hideRegisterPassword;
                  });
                },
              ),
            ),
            obscureText: pageController.hideRegisterPassword,
          ),
          SizedBox(
            height: 24,
          ),
          TextFormField(
            focusNode: pageController.registerPasswordRepeatFocusNode,
            onChanged: (value) {
              pageController.registerPasswordConfirm = value;
            },
            validator: (_) {
              if (pageController.registerPasswordConfirm !=
                  pageController.registerPassword) {
                return FunctionPool.getStringRes(
                  key: 'confirmFailtureStr',
                  language: language,
                );
              }
              return null;
            },
            style: TextStyle(
              color: Colors.blue,
              fontSize: 20,
            ),
            decoration: InputDecoration(
              filled: true,
              labelText: FunctionPool.getStringRes(
                key: 'passwordConfirmHintStr',
                language: language,
              ),
              hintText: FunctionPool.getStringRes(
                key: 'passwordConfirmHintStr',
                language: language,
              ),
              icon: Icon(
                Icons.lock,
                size: 30,
              ),
              border: OutlineInputBorder(),
              suffixIcon: GestureDetector(
                child: Icon(pageController.hideRegisterPasswordRepeat
                    ? Icons.visibility
                    : Icons.visibility_off),
                onTap: () {
                  setState(() {
                    pageController.hideRegisterPasswordRepeat =
                        !pageController.hideRegisterPasswordRepeat;
                  });
                },
              ),
            ),
            obscureText: pageController.hideRegisterPasswordRepeat,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: !pageController.isRegisterProcessing
                ? GestureDetector(
                    onTap: () {
                      pageController.register(context, language: language);
                    },
                    child: ClipOval(
                      child: Container(
                        color: Colors.blue,
                        padding: const EdgeInsets.all(20),
                        child: Icon(
                          Icons.keyboard_arrow_right,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
          ),
        ],
      ),
    );
  }

  Row buildSwitchRow({Language language}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        FlatButton.icon(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          disabledColor: Colors.blue,
          icon: Icon(
            Icons.create,
            color: pageController.inLoginPage
                ? Colors.grey[100]
                : Colors.grey[300],
            size: pageController.inLoginPage ? 40 : 24,
          ),
          onPressed: !pageController.inLoginPage
              ? () {
                  pageController.switchToLoginTab();
                }
              : null,
          label: Text(
            FunctionPool.getStringRes(
              key: 'loginStr',
              language: language,
            ),
            style: TextStyle(
              color: pageController.inLoginPage
                  ? Colors.grey[100]
                  : Colors.grey[300],
              fontSize: pageController.inLoginPage ? 24 : 18,
            ),
          ),
        ),
        FlatButton.icon(
          disabledColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          icon: Icon(
            Icons.add,
            color: !pageController.inLoginPage
                ? Colors.grey[100]
                : Colors.grey[300],
            size: !pageController.inLoginPage ? 40 : 24,
          ),
          onPressed: pageController.inLoginPage
              ? pageController.switchToRegisterTab
              : null,
          label: Text(
            FunctionPool.getStringRes(
              key: 'registerStr',
              language: language,
            ),
            style: TextStyle(
              color: !pageController.inLoginPage
                  ? Colors.grey[100]
                  : Colors.grey[300],
              fontSize: !pageController.inLoginPage ? 24 : 18,
            ),
          ),
        ),
      ],
    );
  }

  Form buildLoginForm(BuildContext context, {Language language}) {
    return Form(
      key: pageController.loginFormKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Text(
              FunctionPool.getStringRes(
                key: 'loginStr',
                language: language,
              ),
              style: TextStyle(
                shadows: [
                  Shadow(
                    color: Colors.blue[300],
                    offset: const Offset(4, 4),
                    blurRadius: 8,
                  ),
                ],
                fontSize: 40,
                color: Colors.blue,
              ),
            ),
          ),
          TextFormField(
            onChanged: (value) {
              pageController.loginUsername = value;
              //print(Localizations.localeOf(context).languageCode);
            },
            onFieldSubmitted: (value) {
              FocusScope.of(context)
                  .requestFocus(pageController.loginPasswordFocusNode);
            },
            style: TextStyle(
              color: Colors.blue,
              fontSize: 20,
            ),
            decoration: InputDecoration(
              filled: true,
              labelText: FunctionPool.getStringRes(
                key: 'usernameStr',
                language: language,
              ),
              hintText: FunctionPool.getStringRes(
                key: 'usernameStr',
                language: language,
              ),
              icon: Icon(
                Icons.person,
                size: 30,
              ),
              border: OutlineInputBorder(),
            ),
            validator: (_) {
              return pageController.loginUsernameValidate(language: language);
            },
          ),
          SizedBox(
            height: 24,
          ),
          TextFormField(
            focusNode: pageController.loginPasswordFocusNode,
            onChanged: (value) {
              pageController.loginPassword = value;
            },
            onFieldSubmitted: (_) {},
            validator: (_) {
              return pageController.loginPasswordValidate(language: language);
            },
            style: TextStyle(
              color: Colors.blue,
              fontSize: 20,
            ),
            decoration: InputDecoration(
              filled: true,
              labelText: FunctionPool.getStringRes(
                key: 'passwordStr',
                language: language,
              ),
              hintText: FunctionPool.getStringRes(
                key: 'passwordStr',
                language: language,
              ),
              icon: Icon(
                Icons.lock,
                size: 30,
              ),
              border: OutlineInputBorder(),
              suffixIcon: GestureDetector(
                child: Icon(pageController.hideLoginPassword
                    ? Icons.visibility
                    : Icons.visibility_off),
                onTap: () {
                  setState(() {
                    pageController.hideLoginPassword =
                        !pageController.hideLoginPassword;
                  });
                },
              ),
            ),
            obscureText: pageController.hideLoginPassword,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FlatButton(
              child: Text(
                FunctionPool.getStringRes(
                  key: 'forgotPasswordStr',
                  language: language,
                ),
              ),
              onPressed: () {
                Navigator.of(context)
                    .push(SlideBottomRoute(page: AccountRecovery()));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: !pageController.isLoginProcessing
                ? GestureDetector(
                    onTap: () {
                      pageController.login(context, language: language);
                    },
                    child: ClipOval(
                      child: Container(
                        color: Colors.blue,
                        padding: const EdgeInsets.all(20),
                        child: Icon(
                          Icons.keyboard_arrow_right,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
          ),
        ],
      ),
    );
  }
}
