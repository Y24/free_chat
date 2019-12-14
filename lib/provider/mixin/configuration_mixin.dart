import 'package:flutter/material.dart';
import 'package:free_chat/entity/enums.dart';
import 'package:free_chat/provider/base_provider.dart';
import 'package:free_chat/provider/configuration_provider.dart';
import 'package:free_chat/provider/entity/configuration_entity.dart';
import 'package:free_chat/provider/entity/provider_code.dart';
import 'package:free_chat/provider/entity/provider_entity.dart';
import 'package:free_chat/util/function_pool.dart';

/// [ConfigurationMixin] is aimed at simplifying the usage of [ConfigurationProvider].
///
/// Once you have mixed the target *class* with [ConfigurationMixin],
/// you can easily call the public methods exposed by [ConfigurationMixin] to do the related bussiness work
/// and have no need to control the [Provider] yourself.
///
/// Note: In some ways, [ConfigurationMixin] can be regarded as public `APIs` of the corresponding [ConfigurationProvider].
class ConfigurationMixin {
  IProvider _provider;
  Future<bool> init(String username) {
    _provider = ConfigurationProvider(username: username);
    return _provider.init();
  }

  Future<String> getLanguageCode() async {
    _provider.setEntity(
        ProviderEntity(code: ConfigurationProviderCode.queryLanguage));
    return await _provider.provide();
  }

  Future<bool> updateLanguageCode(String languageCode) async {
    _provider.setEntity(ProviderEntity(
        code: ConfigurationProviderCode.updateLanguage,
        content: ConfigurationEntity(content: languageCode)));
    return await _provider.provide();
  }

  Future<ThemeDataCode> getThemeDataCode() async {
    _provider
        .setEntity(ProviderEntity(code: ConfigurationProviderCode.queryTheme));
    return FunctionPool.getThemeDataCodeFromStr(await _provider.provide());
  }

  Future<bool> updateThemeDataCode(ThemeDataCode code) async {
    _provider.setEntity(ProviderEntity(
        code: ConfigurationProviderCode.updateTheme,
        content: ConfigurationEntity(
            content: FunctionPool.getStrFromThemeDataCode(code))));
    return await _provider.provide();
  }

  Future<Color> getPrimaryColor() async {
    _provider.setEntity(
        ProviderEntity(code: ConfigurationProviderCode.queryPrimaryColor));
    return FunctionPool.getPrimaryColorFromStr(await _provider.provide());
  }

  Future<bool> updatePrimaryColor(Color color) async {
    _provider.setEntity(ProviderEntity(
        code: ConfigurationProviderCode.updatePrimaryColor,
        content: ConfigurationEntity(
            content: FunctionPool.getStrFromPrimaryColor(color))));
    return await _provider.provide();
  }
}
