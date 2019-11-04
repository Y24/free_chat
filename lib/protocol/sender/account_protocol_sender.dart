import 'dart:convert';
import 'dart:io';

import 'package:free_chat/entity/enums.dart';
import 'package:free_chat/protocol/entity/account_protocol_entity.dart';
import 'package:free_chat/protocol/sender/base_protocol_sender.dart';

// TODO: this class should be totally refactored like class ``ChatProtocolSender``;
abstract class IAccountProtocolSender implements IProtocolSender {
  Future<LoginStatus> login();
  Future<LogoutOrCleanUpStatus> logout();
  Future<LogoutOrCleanUpStatus> cleanUp();
  Future<RegisterStatus> register();
}

class AccountProtocol extends BaseProtocolSender
    implements IAccountProtocolSender {
  final String username;
  final String password;

  AccountProtocolEntity protocolEntity;
  AccountProtocol({this.username, this.password});
  @override
  String get urlPrefix => 'account';
  @override
  Future<WebSocket> init() {
    return super.setUp();
  }

  @override
  send() async {
    switch (protocolEntity.head.code as AccountProtocolCode) {
      case AccountProtocolCode.login:
        return await login();
      case AccountProtocolCode.logout:
        return await logout();
      case AccountProtocolCode.register:
        return await register();
      case AccountProtocolCode.cleanUp:
        return await cleanUp();
    }
    print('Here is a bug to be fixed at AccountProtocol line 30');
  }

  void _send(AccountProtocolCode code) {
    protocolEntity = AccountProtocolEntity(
      head: AccountHeadEntity(
        id: username,
        code: code,
        timestamp: DateTime.now(),
      ),
      body: AccountBodyEntity(content: password),
    );
    webSocket.add(json.encode(protocolEntity.toJson()));
  }

  Future<LoginStatus> login() async {
    if (!connected && await setUp() == null) return LoginStatus.serverError;
    _send(AccountProtocolCode.login);
    try {
      final response =
          AccountProtocolEntity.fromJson(json.decode(await webSocket.first));
      if (response.head.code as bool)
        return LoginStatus.authenticationSuccess;
      else
        return LoginStatus.authenticationFailture;
    } catch (e) {
      return LoginStatus.serverError;
    }
  }

  @override
  Future<LogoutOrCleanUpStatus> cleanUp() async {
    if (!connected && await setUp() == null)
      return LogoutOrCleanUpStatus.serverError;
    _send(AccountProtocolCode.cleanUp);
    try {
      final response =
          AccountProtocolEntity.fromJson(json.decode(await webSocket.first));
      if (response.head.code as bool)
        return LogoutOrCleanUpStatus.success;
      else {
        if (response.body.content == 'server')
          return LogoutOrCleanUpStatus.serverError;
        if (response.body.content == 'password')
          return LogoutOrCleanUpStatus.authenticationFailture;
        return LogoutOrCleanUpStatus.serverError;
      }
    } catch (e) {
      return LogoutOrCleanUpStatus.serverError;
    }
  }

  @override
  Future<LogoutOrCleanUpStatus> logout() async {
    if (!connected && await setUp() == null)
      return LogoutOrCleanUpStatus.serverError;
    _send(AccountProtocolCode.logout);
    try {
      final response =
          AccountProtocolEntity.fromJson(json.decode(await webSocket.first));
      if (response.head.code as bool)
        return LogoutOrCleanUpStatus.success;
      else {
        if (response.body.content == 'server')
          return LogoutOrCleanUpStatus.serverError;
        if (response.body.content == 'password')
          return LogoutOrCleanUpStatus.authenticationFailture;
        return LogoutOrCleanUpStatus.serverError;
      }
    } catch (e) {
      return LogoutOrCleanUpStatus.serverError;
    }
  }

  @override
  Future<RegisterStatus> register() async {
    if (!connected && await setUp() == null) return RegisterStatus.serverError;
    _send(AccountProtocolCode.register);
    try {
      final response =
          AccountProtocolEntity.fromJson(json.decode(await webSocket.first));
      if (response.head.code as bool)
        return RegisterStatus.success;
      else {
        if (response.body.content == 'server')
          return RegisterStatus.serverError;
        if (response.body.content == 'username')
          return RegisterStatus.invalidUsername;
        if (response.body.content == 'permission')
          return RegisterStatus.permissionDenied;
        return RegisterStatus.unknownError;
      }
    } catch (e) {
      return RegisterStatus.unknownError;
    }
  }

  @override
  Future<void> dispose() async {
    await super.close();
  }

  @override
  get entity => protocolEntity;

  @override
  void setEntity(entity) {
    protocolEntity = entity;
  }
}
