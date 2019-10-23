import 'dart:async';

import 'package:flutter/material.dart';
import 'package:free_chat/UI/account_recovery.dart';
import 'package:free_chat/UI/welcome.dart';
import 'package:free_chat/configuration/configuration.dart';
import 'package:free_chat/entity/enums.dart';
import 'package:free_chat/services/accout_service.dart';
import 'package:free_chat/services/mysql_service.dart';
import 'package:free_chat/util/function_pool.dart';
import 'package:free_chat/util/ui/clip_oval_logo.dart';
import 'package:free_chat/util/ui/custom_style.dart';
import 'package:free_chat/util/ui/failture_snack_bar.dart';
import 'package:free_chat/util/ui/page_tansitions/fade_route.dart';
import 'package:free_chat/util/ui/page_tansitions/slide_route.dart';
import 'package:free_chat/util/validator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle =
        Configuration.appName[Provider.of<LanguageState>(context).language];

    return MaterialApp(
      title: appTitle,
      theme: Provider.of<CustomThemeDataState>(context).themeData,
      home: Scaffold(
        body: LoginUI(),
      ),
    );
  }
}

// Create a Form widget.
class LoginUI extends StatefulWidget {
  @override
  LoginUIState createState() {
    return LoginUIState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class LoginUIState extends State<LoginUI> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();
  String _loginUsername = '', _loginPassword = '';
  String _registerUsername = '',
      _registerPassword = '',
      _registerPasswordConfirm = '';
  bool hideLoginPassword = true;
  bool hideRegisterPassword = true;
  bool hideRegisterPasswordRepeat = true;
  bool isLoginProcessing = false;
  bool isRegisterProcessing = false;
  bool inLoginPage = true;
  FocusNode loginPasswordFocusNode = FocusNode();
  FocusNode registerPasswordFocusNode = FocusNode();
  FocusNode registerPasswordRepeatFocusNode = FocusNode();
  AccountService accountService = AccountService(mysqlService: MysqlService());
  @override
  Widget build(BuildContext context) {
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
                  child: inLoginPage
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
      key: registerFormKey,
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
              _registerUsername = value;
            },
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(registerPasswordFocusNode);
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
              if (_registerUsername.isEmpty) {
                return FunctionPool.getStringRes(
                  key: 'usernameValidatorEmptyStr',
                  language: language,
                );
              }
              if (!Validator.validateUsername(_registerUsername)) {
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
            focusNode: registerPasswordFocusNode,
            onChanged: (value) {
              _registerPassword = value;
            },
            onFieldSubmitted: (value) {
              FocusScope.of(context)
                  .requestFocus(registerPasswordRepeatFocusNode);
            },
            validator: (_) {
              if (_registerPassword.isEmpty) {
                return FunctionPool.getStringRes(
                  key: 'passwordValidatorEmptyStr',
                  language: language,
                );
              }
              if (!Validator.validatePassword(_registerPassword)) {
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
                child: Icon(hideRegisterPassword
                    ? Icons.visibility
                    : Icons.visibility_off),
                onTap: () {
                  setState(() {
                    hideRegisterPassword = !hideRegisterPassword;
                  });
                },
              ),
            ),
            obscureText: hideRegisterPassword,
          ),
          SizedBox(
            height: 24,
          ),
          TextFormField(
            focusNode: registerPasswordRepeatFocusNode,
            onChanged: (value) {
              _registerPasswordConfirm = value;
            },
            validator: (_) {
              if (_registerPasswordConfirm != _registerPassword) {
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
                child: Icon(hideRegisterPasswordRepeat
                    ? Icons.visibility
                    : Icons.visibility_off),
                onTap: () {
                  setState(() {
                    hideRegisterPasswordRepeat = !hideRegisterPasswordRepeat;
                  });
                },
              ),
            ),
            obscureText: hideRegisterPasswordRepeat,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: !isRegisterProcessing
                ? GestureDetector(
                    onTap: () {
                      if (!registerFormKey.currentState.validate()) return;
                      setState(() {
                        isRegisterProcessing = true;
                      });
                      Timer timer;
                      timer = Timer.periodic(
                          Duration(seconds: Configuration.connectionMaxSeconds),
                          (time) {
                        if (time.tick > Configuration.maxConnectionTryTimes) {
                          time.cancel();
                          setState(() {
                            isRegisterProcessing = false;
                          });
                          return;
                        }

                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text(
                            FunctionPool.getStringRes(
                                key: 'timeOutStr', language: language),
                            style: TextStyle(color: Colors.red),
                          ),
                          backgroundColor: Colors.grey[100],
                          action: SnackBarAction(
                            label: FunctionPool.getStringRes(
                                key: 'cancelStr', language: language),
                            onPressed: () {
                              timer.cancel();
                              setState(() {
                                isRegisterProcessing = false;
                              });
                            },
                          ),
                        ));
                      });
                      accountService
                          .register(
                        username: _registerUsername,
                        password: _registerPassword,
                        role: Role.user,
                      )
                          .then(
                        (onValue) {
                          timer.cancel();
                          switch (onValue) {
                            case RegisterStatus.serverError:
                              Scaffold.of(context)
                                  .showSnackBar(FailtureSnackBar.newInstance(
                                message: FunctionPool.getStringRes(
                                  key: 'serverErrorStr',
                                  language: language,
                                ),
                              ));
                              setState(() {
                                isRegisterProcessing = false;
                              });
                              break;
                            case RegisterStatus.timeoutError:
                              Scaffold.of(context)
                                  .showSnackBar(FailtureSnackBar.newInstance(
                                message: FunctionPool.getStringRes(
                                  key: 'timeOutStr',
                                  language: language,
                                ),
                              ));
                              setState(() {
                                isRegisterProcessing = false;
                              });
                              break;
                            case RegisterStatus.InvalidUsername:
                              Scaffold.of(context)
                                  .showSnackBar(FailtureSnackBar.newInstance(
                                message: FunctionPool.getStringRes(
                                  key: 'usernameInvalidStr',
                                  language: language,
                                ),
                              ));
                              setState(() {
                                isRegisterProcessing = false;
                              });
                              break;
                            case RegisterStatus.success:
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(
                                  FunctionPool.getStringRes(
                                    key: 'registerSuccessStr',
                                    language: language,
                                  ),
                                  style: TextStyle(color: Colors.green),
                                ),
                                backgroundColor: Colors.grey[100],
                                action: SnackBarAction(
                                  onPressed: () {
                                    setState(() {
                                      _registerUsername = _registerPassword =
                                          _registerPasswordConfirm = '';
                                      inLoginPage = true;
                                    });
                                  },
                                  label: FunctionPool.getStringRes(
                                    key: 'loginStr',
                                    language: language,
                                  ),
                                ),
                              ));
                              setState(() {
                                isRegisterProcessing = false;
                              });
                              break;
                            case RegisterStatus.unknownError:
                              Scaffold.of(context)
                                  .showSnackBar(FailtureSnackBar.newInstance(
                                message: FunctionPool.getStringRes(
                                  key: 'unknownErrorStr',
                                  language: language,
                                ),
                              ));
                              setState(() {
                                isRegisterProcessing = false;
                              });
                              break;
                            default:
                          }
                        },
                      );
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
            color: inLoginPage ? Colors.grey[100] : Colors.grey[300],
            size: inLoginPage ? 40 : 24,
          ),
          onPressed: !inLoginPage
              ? () {
                  setState(() {
                    inLoginPage = true;
                    // clean work
                    _loginUsername = _loginPassword = _registerUsername =
                        _registerPassword = _registerPasswordConfirm = '';
                  });
                }
              : null,
          label: Text(
            FunctionPool.getStringRes(
              key: 'loginStr',
              language: language,
            ),
            style: TextStyle(
              color: inLoginPage ? Colors.grey[100] : Colors.grey[300],
              fontSize: inLoginPage ? 24 : 18,
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
            color: !inLoginPage ? Colors.grey[100] : Colors.grey[300],
            size: !inLoginPage ? 40 : 24,
          ),
          onPressed: inLoginPage
              ? () {
                  setState(() {
                    inLoginPage = false;
                    _loginUsername = _loginPassword = _registerUsername =
                        _registerPassword = _registerPasswordConfirm = '';
                  });
                }
              : null,
          label: Text(
            FunctionPool.getStringRes(
              key: 'registerStr',
              language: language,
            ),
            style: TextStyle(
              color: !inLoginPage ? Colors.grey[100] : Colors.grey[300],
              fontSize: !inLoginPage ? 24 : 18,
            ),
          ),
        ),
      ],
    );
  }

  Form buildLoginForm(BuildContext context, {Language language}) {
    return Form(
      key: loginFormKey,
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
              _loginUsername = value;
              //print(Localizations.localeOf(context).languageCode);
            },
            onFieldSubmitted: (value) {
              FocusScope.of(context).requestFocus(loginPasswordFocusNode);
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
              if (_loginUsername.isEmpty) {
                return FunctionPool.getStringRes(
                  key: 'usernameValidatorEmptyStr',
                  language: language,
                );
              }
              if (!Validator.validateUsername(_loginUsername)) {
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
            focusNode: loginPasswordFocusNode,
            onChanged: (value) {
              _loginPassword = value;
            },
            onFieldSubmitted: (_) {},
            validator: (_) {
              if (_loginPassword.isEmpty) {
                return FunctionPool.getStringRes(
                  key: 'passwordValidatorEmptyStr',
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
                key: 'passwordStr',
                language: language,
              ),
              icon: Icon(
                Icons.lock,
                size: 30,
              ),
              border: OutlineInputBorder(),
              suffixIcon: GestureDetector(
                child: Icon(hideLoginPassword
                    ? Icons.visibility
                    : Icons.visibility_off),
                onTap: () {
                  setState(() {
                    hideLoginPassword = !hideLoginPassword;
                  });
                },
              ),
            ),
            obscureText: hideLoginPassword,
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
            child: !isLoginProcessing
                ? GestureDetector(
                    onTap: () {
                      Timer timer;
                      if (!loginFormKey.currentState.validate()) return;
                      setState(() {
                        isLoginProcessing = true;
                      });
                      timer = Timer.periodic(
                          Duration(seconds: Configuration.connectionMaxSeconds),
                          (time) {
                        if (time.tick > Configuration.maxConnectionTryTimes) {
                          time.cancel();
                          setState(() {
                            isLoginProcessing = false;
                          });
                          return;
                        }
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text(
                            FunctionPool.getStringRes(
                                key: 'timeOutStr', language: language),
                            style: TextStyle(color: Colors.red),
                          ),
                          backgroundColor: Colors.grey[100],
                          duration: const Duration(seconds: 5),
                          action: SnackBarAction(
                            label: FunctionPool.getStringRes(
                                key: 'cancelStr', language: language),
                            onPressed: () {
                              timer.cancel();
                              setState(() {
                                isLoginProcessing = false;
                              });
                            },
                          ),
                        ));
                      });
                      accountService
                          .login(
                        username: _loginUsername,
                        password: _loginPassword,
                      )
                          .then(
                        (onValue) {
                          timer.cancel();
                          switch (onValue) {
                            case LoginStatus.serverError:
                              Scaffold.of(context)
                                  .showSnackBar(FailtureSnackBar.newInstance(
                                      message: FunctionPool.getStringRes(
                                key: 'serverErrorStr',
                                language: language,
                              )));
                              setState(() {
                                isLoginProcessing = false;
                              });
                              break;
                            case LoginStatus.timeoutError:
                              Scaffold.of(context)
                                  .showSnackBar(FailtureSnackBar.newInstance(
                                      message: FunctionPool.getStringRes(
                                key: 'timeOutStr',
                                language: language,
                              )));
                              setState(() {
                                isLoginProcessing = false;
                              });
                              break;
                            case LoginStatus.authenticationFailture:
                              Scaffold.of(context)
                                  .showSnackBar(FailtureSnackBar.newInstance(
                                      message: FunctionPool.getStringRes(
                                key: 'authenticationFailtureStr',
                                language: language,
                              )));
                              setState(() {
                                isLoginProcessing = false;
                              });
                              break;
                            case LoginStatus.authenticationsuccess:
                              SharedPreferences.getInstance().then((prefs) {
                                FunctionPool.addAccountInfo(prefs,
                                    target: 'loginStatus', value: true);
                                FunctionPool.addAccountInfo(prefs,
                                    target: 'loginAccountUsername',
                                    value: _loginUsername);
                               
                                Navigator.of(context).pushAndRemoveUntil(
                                    FadeRoute(
                                        page: WelcomePage(
                                      language: language,
                                      username: _loginUsername,
                                      themeData: Theme.of(context),
                                    )),
                                    (route) => route == null);
                                setState(() {
                                  isLoginProcessing = false;
                                });
                              });
                              break;
                            case LoginStatus.unknownError:
                              Scaffold.of(context)
                                  .showSnackBar(FailtureSnackBar.newInstance(
                                      message: FunctionPool.getStringRes(
                                key: 'unknownErrorStr',
                                language: language,
                              )));
                              setState(() {
                                isLoginProcessing = false;
                              });
                              break;
                            default:
                          }
                        },
                      );
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
