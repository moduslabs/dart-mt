///
/// Editor class
///
/// Class to open a temporary file in $EDITOR and return the edited file as a string.
///

import 'dart:io';
import 'dart:io' show Platform;

class Editor {
  late final String _editor;
  String _tempFilename = '';
  late final String _defaultText;

  static int nextFileNumber = 0;
  Editor({fn = '', defaultText = ''}) {
    _defaultText = defaultText;
    final tmp = Directory.systemTemp.path;
    while (_tempFilename.length < 1) {
      final fn = '$tmp/mt_editor_$nextFileNumber';
      nextFileNumber++;
      File f = File(_tempFilename);
      if (!f.existsSync()) {
        this._tempFilename = fn;
        break;
      }
    }
    final f = File(_tempFilename);
    f.writeAsString(_defaultText);
    Map<String, String> env = Platform.environment;
    String? e = env['EDITOR'];
    if (e == null) {
      print('*** Warning: no EDITOR defined, using vi');
      _editor = '/bin/vi';
    } else {
      _editor = e;
    }
  }

  Future<List<String>> edit() async {
    final process = await Process.start(
        '$_editor', //
        [_tempFilename], //
        mode: ProcessStartMode.inheritStdio, //
        runInShell: true //
        );

    final result = await process.exitCode;
    File f = File(_tempFilename);
    if (f.existsSync()) {
      if (result == 0) {
        final List<String> res = f.readAsLinesSync();
        f.delete();
        String s =  res.join('\n');
        return s == _defaultText ? [] : res;
      } else {
        f.delete();
      }
    }
    return [];
  }
}
