import 'package:flutter/material.dart';

class HandleResultEntity {
  static final HandleResultEntity errorResultEntity =
      HandleResultEntity(code: null, content: null);
  final code;
  dynamic content;
  HandleResultEntity({this.code, this.content});
  @override
  int get hashCode => hashValues(code, content);
  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final HandleResultEntity typedOther = other;
    return code == typedOther.code && content == typedOther.content;
  }

  @override
  String toString() =>
      'HandleResultEntity( { code: $code, content: $content } )';
}
