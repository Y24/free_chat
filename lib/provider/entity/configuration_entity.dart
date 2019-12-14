import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ConfigurationEntity {
  static final emptyConfigurationEntity = ConfigurationEntity(content: '');
  final content;
  ConfigurationEntity({
    this.content,
  });
  ConfigurationEntity.fromMap(Map<String, dynamic> map)
      : assert(map != null),
        content = map['content'];
  Map<String, dynamic> toMap() => <String, dynamic>{
        'content': content,
      };
  @override
  int get hashCode => hashValues(content, content);
  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final ConfigurationEntity typedOther = other;
    return content == typedOther.content;
  }

  @override
  String toString() => 'ConfigurationEntity( { content: $content } )';
}
