import 'package:ansicolor/ansicolor.dart';

class console {
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
//      ..white(bg: true, bold: true)
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
      ..black(bold: true)
      ;
    print(pen('\n$message'));
  }
}
