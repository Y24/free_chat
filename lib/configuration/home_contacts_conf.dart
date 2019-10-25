import 'package:flutter/material.dart';
import 'package:free_chat/entity/enums.dart';

abstract class HomeContactsConf {
  static final index = ['peopleStr', 'groupStr'];
  static final tabIcons = [
    Icons.person,
    Icons.group,
  ];
  static final strPool = {
    'peopleStr': {
      Language.en: [
        'favorite',
        'all',
        'customGroup',
      ],
      Language.zh: [
        '标注',
        '所有',
        '分组',
      ],
    },
    'groupStr': {
      Language.en: [
        'favorite',
        'all',
        'customGroup',
      ],
      Language.zh: [
        '标注',
        '所有',
        '分类',
      ],
    },
  };
}
