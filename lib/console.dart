import 'dart:io';
import 'package:ansicolor/ansicolor.dart';

class console {
  //
  // output
  //
  static void log(message) {
    AnsiPen pen = new AnsiPen();
    pen.reset();
    print(pen(message));
  }

  static void bold(message) {
    AnsiPen pen = new AnsiPen();
    pen
      ..reset()
      ..white(bold: true);
    print(pen(message));
  }

  static void warn(message) {
    AnsiPen pen = new AnsiPen();
    pen
      ..reset()
      ..yellow(bold: true);
    print(pen(message));
  }

  static void success(message) {
    AnsiPen pen = new AnsiPen();
    pen
      ..reset()
//      ..white(bg: true, bold: true)
      ..green(bold: true);
    print(pen(message));
  }

  static void error(message) {
    AnsiPen pen = new AnsiPen();
    pen
      ..reset()
//      ..white(bg: true, bold: true)
      ..red(bold: true);
    print(pen(message));
  }

  static void dump(message) {
    if (message.length == 0) {
      return;
    }
    AnsiPen pen = new AnsiPen();
    pen
      ..reset()
      ..white(bg: true, bold: true)
      ..black(bold: true);
    print(pen('\n$message'));
  }

  //
  // input
  //
  static bool yesOrNo(String? prompt) {
    if (prompt != null) {
      stdout.write(prompt);
    }
    stdin.lineMode = false;
    final b = String.fromCharCode(stdin.readByteSync());
    stdin.lineMode = true;
    if (b != '\n') {
      print('');
    }

    if (b == 'y' || b == 'Y') {
      return true;
    } else {
      return false;
    }
  }
}
