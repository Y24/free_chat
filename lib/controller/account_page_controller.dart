import 'dart:async';

import 'package:flutter/material.dart';
import 'package:free_chat/configuration/configuration.dart';
import 'package:free_chat/controller/base_page_controller.dart';
import 'package:free_chat/entity/enums.dart';
import 'package:free_chat/page/account_page.dart';
import 'package:free_chat/page/welcome.dart';
import 'package:free_chat/protocol/entity/account_protocol_entity.dart';
import 'package:free_chat/protocol/sender/account_protocol_sender.dart';
import 'package:free_chat/protocol/sender/base_protocol_sender.dart';
import 'package:free_chat/provider/account_provider.dart';
import 'package:free_chat/provider/base_provider.dart';
import 'package:free_chat/provider/entity/account_entity.dart';
import 'package:free_chat/provider/entity/provider_code.dart';
import 'package:free_chat/provider/entity/provider_entity.dart';
import 'package:free_chat/util/function_pool.dart';
import 'package:free_chat/util/ui/failture_snack_bar.dart';
import 'package:free_chat/util/ui/page_tansitions/fade_route.dart';
import 'package:free_chat/util/validator.dart';

class AccountPageController extends BasePageController {
  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();
  IProvider provider;
  bool providerInited = false;
  String loginUsername = '', loginPassword = '';
  String registerUsername = '',
      registerPassword = '',
      registerPasswordConfirm = '';
  bool hideLoginPassword = true;
  bool hideRegisterPassword = true;
  bool hideRegisterPasswordRepeat = true;
  bool isLoginProcessing = false;
  bool isRegisterProcessing = false;
  bool inLoginPage = true;
  FocusNode loginPasswordFocusNode = FocusNode();
  FocusNode registerPasswordFocusNode = FocusNode();
  FocusNode registerPasswordRepeatFocusNode = FocusNode();
  IProtocolSender accountProtocol;
  @override
  String get path => r'lib/page/account_page.dart';
  @override
  void dispose() {
    provider?.close();
    accountProtocol?.dispose();
  }

  @override
  void init({State state}) {
    super.init(state: state);
    providerInited = false;
    provider = AccountProvider()
      ..init().then((result) async {
        print('provider init result: $result');
        (state as LoginPageState).update(() {
          providerInited = result;
        });
      });
  }

  void switchToLoginTab() {
    state.update(() {
      inLoginPage = true;
      // clean work
      loginUsername = loginPassword =
          registerUsername = registerPassword = registerPasswordConfirm = '';
    });
  }

  void switchToRegisterTab() {
    state.update(() {
      inLoginPage = false;
      loginUsername = loginPassword =
          registerUsername = registerPassword = registerPasswordConfirm = '';
    });
  }

  String loginUsernameValidate({Language language}) {
    if (loginUsername.isEmpty) {
      return FunctionPool.getStringRes(
        key: 'usernameValidatorEmptyStr',
        language: language,
      );
    }
    if (!Validator.validateUsername(loginUsername)) {
      return FunctionPool.getStringRes(
        key: 'usernameInvalidStr',
        language: language,
      );
    }

    return null;
  }

  String loginPasswordValidate({Language language}) {
    if (loginPassword.isEmpty) {
      return FunctionPool.getStringRes(
        key: 'passwordValidatorEmptyStr',
        language: language,
      );
    }
    return null;
  }

  void register(BuildContext context, {Language language}) {
    if (!registerFormKey.currentState.validate()) return;
    state.update(() {
      isRegisterProcessing = true;
    });
    Timer timer;
    timer = Timer.periodic(
        Duration(seconds: Configuration.connectionMaxSeconds), (time) {
      if (time.tick > Configuration.maxConnectionTryTimes) {
        time.cancel();
        state.update(() {
          isRegisterProcessing = false;
        });
        return;
      }

      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
          FunctionPool.getStringRes(key: 'timeOutStr', language: language),
          style: TextStyle(color: Colors.red),
        ),
        backgroundColor: Colors.grey[100],
        action: SnackBarAction(
          label:
              FunctionPool.getStringRes(key: 'cancelStr', language: language),
          onPressed: () {
            timer.cancel();
            state.update(() {
              isRegisterProcessing = false;
            });
          },
        ),
      ));
    });
    accountProtocol?.dispose();
    accountProtocol = AccountProtocol(
      username: registerUsername,
      password: registerPassword,
    );

    accountProtocol.init()
      ..then((result) {
        if (result != null) {
          AccountProtocolEntity protocolEntity = AccountProtocolEntity(
              head: AccountHeadEntity(
                code: AccountProtocolCode.register,
                id: registerUsername,
                timestamp: DateTime.now(),
              ),
              body: AccountBodyEntity(
                content: registerPassword,
              ));
          accountProtocol.setEntity(protocolEntity);
          accountProtocol.send().then(
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
                  state.update(() {
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
                  state.update(() {
                    isRegisterProcessing = false;
                  });

                  break;
                case RegisterStatus.invalidUsername:
                  Scaffold.of(context)
                      .showSnackBar(FailtureSnackBar.newInstance(
                    message: FunctionPool.getStringRes(
                      key: 'usernameInvalidStr',
                      language: language,
                    ),
                  ));
                  state.update(() {
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
                        state.update(() {
                          registerUsername =
                              registerPassword = registerPasswordConfirm = '';
                          inLoginPage = true;
                        });
                      },
                      label: FunctionPool.getStringRes(
                        key: 'loginStr',
                        language: language,
                      ),
                    ),
                  ));
                  state.update(() {
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
                  state.update(() {
                    isRegisterProcessing = false;
                  });
                  break;
                default:
              }
            },
          );
        }
      });
  }

  void login(BuildContext context, {Language language}) {
    Timer timer;
    if (!loginFormKey.currentState.validate()) return;
    state.update(() {
      isLoginProcessing = true;
    });
    timer = Timer.periodic(
        Duration(seconds: Configuration.connectionMaxSeconds), (time) {
      if (time.tick > Configuration.maxConnectionTryTimes) {
        time.cancel();
        state.update(() {
          isLoginProcessing = true;
        });
        return;
      }
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
          FunctionPool.getStringRes(key: 'timeOutStr', language: language),
          style: TextStyle(color: Colors.red),
        ),
        backgroundColor: Colors.grey[100],
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label:
              FunctionPool.getStringRes(key: 'cancelStr', language: language),
          onPressed: () {
            timer.cancel();
            state.update(() {
              isLoginProcessing = true;
            });
          },
        ),
      ));
    });
    accountProtocol?.dispose();
    accountProtocol = AccountProtocol(
      username: loginUsername,
      password: loginPassword,
    );

    accountProtocol.init()
      ..then((result) {
        if (result != null) {
          AccountProtocolEntity protocolEntity = AccountProtocolEntity(
              head: AccountHeadEntity(
                code: AccountProtocolCode.login,
                id: loginUsername,
                timestamp: DateTime.now(),
              ),
              body: AccountBodyEntity(
                content: loginPassword,
              ));
          accountProtocol.setEntity(protocolEntity);
          accountProtocol.send().then(
            (onValue) async {
              timer.cancel();

              switch (onValue) {
                case LoginStatus.serverError:
                  Scaffold.of(context)
                      .showSnackBar(FailtureSnackBar.newInstance(
                          message: FunctionPool.getStringRes(
                    key: 'serverErrorStr',
                    language: language,
                  )));
                  state.update(() {
                    isLoginProcessing = true;
                  });
                  break;
                case LoginStatus.timeoutError:
                  Scaffold.of(context)
                      .showSnackBar(FailtureSnackBar.newInstance(
                          message: FunctionPool.getStringRes(
                    key: 'timeOutStr',
                    language: language,
                  )));
                  state.update(() {
                    isLoginProcessing = true;
                  });
                  break;
                case LoginStatus.authenticationFailture:
                  Scaffold.of(context)
                      .showSnackBar(FailtureSnackBar.newInstance(
                          message: FunctionPool.getStringRes(
                    key: 'authenticationFailtureStr',
                    language: language,
                  )));
                  state.update(() {
                    isLoginProcessing = true;
                  });
                  break;
                case LoginStatus.authenticationSuccess:
                  final accountEntity = AccountEntity(
                    username: loginUsername,
                    password: loginPassword,
                    role: Role.user,
                    loginStatus: true,
                    lastLoginTimestamp: DateTime.now(),
                    lastLogoutTimestamp: DateTime.now(),
                  );
                  print(accountEntity.toMap().toString());
                  provider.setEntity(ProviderEntity(
                      code: AccountProviderCode.login, content: accountEntity));
                  final result = await provider.provide();
                  print('result: $result');
                  Navigator.of(context).pushAndRemoveUntil(
                      FadeRoute(
                          page: WelcomePage(
                        language: language,
                        username: loginUsername,
                        themeData: Theme.of(context),
                      )),
                      (route) => route == null);
                  break;
                case LoginStatus.unknownError:
                  Scaffold.of(context)
                      .showSnackBar(FailtureSnackBar.newInstance(
                          message: FunctionPool.getStringRes(
                    key: 'unknownErrorStr',
                    language: language,
                  )));
                  state.update(() {
                    isLoginProcessing = true;
                  });
                  break;
                default:
              }
            },
          );
        }
      });
  }
}
