import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

const ID_TEXT = 200;
const ID_EDITTEXT = 201;
const ID_PROGRESS = 202;

final hInstance = GetModuleHandle(nullptr);
String textEntered = '';

class UIDemo {
  UIDemo() {
    _build();
  }

  void _build() {}

  void show() {}
}
