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
    pen..reset();
/*      ..white(bg: true, bold: true)*/
/*      ..black(bold: true);*/
    print(pen('\n$message'));
  }

  //
  // input
  //

  ///
  /// confirm(message)  - prompt for/ask a Yes/No type question
  ///
  /// Optionally print a prompt and wait for ONE character of input in RAW mode (no newline
  ///   required).  Returns true if the character entered is Y (for yes).
  static bool confirm(String? prompt, [bool? defaultAnswer]) {
    if (prompt != null) {
      stdout.write(prompt);
    }

    if (defaultAnswer != null && defaultAnswer) {
      print('Y');
      print('');
      return true;
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

  ///
  /// prompt(message) - prompt user for input and read (and return) one line of text s/he typed in.
  ///
  static String? prompt(String? prompt) {
    if (prompt != null) {
      stdout.write(prompt);
    }
    return stdin.readLineSync();
  }

  static void clear(count, prompt, value) {
    for (int i = 0; i <= count + 1; i++) {
      stdout.write('\x1B[1A');
      stdout.write('\x1B[K');
    }
    print('$prompt$value');
  }

  static String? select(String? prompt, List<String> options,
      [defaultValue = 0]) {
    final count = options.length;

    if (prompt != null) {
      print(prompt);
    }
    for (var i = 0; i < count; i++) {
      print(' ${i + 1} ${options[i]}');
    }
    String? answer =
        console.prompt('Select option 1-$count (${defaultValue + 1}): ');
    if (answer == null) {
      print('');
      print('');
      exit(1);
    }

    var choice;
    try {
      choice = answer == ''
          ? (defaultValue + 1)
          : (answer.length > 0 ? int.parse(answer) : 0);
    } on FormatException {
      return null;
    }
    if (choice < 1 || choice > options.length) {
      choice = defaultValue + 1;
      clear(options.length, prompt, options[defaultValue]);
      return options[defaultValue];
    }
    clear(options.length, prompt, options[choice - 1]);
    return options[choice - 1];
  }
}
