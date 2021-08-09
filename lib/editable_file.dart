///
/// EditableFile class
///
/// Base class that handles common file functions for mt.yaml, pubspec.yaml,
/// CHANGELOG.md, etc.
///

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:mt/console.dart';

abstract class EditableFile {
  late final _path;
  late final _name;
  /// lines before _lines are _head
  final List<String> _head =  [];
  late final List<String> _lines;
  /// lines after _lines are _tail
  final List<String> _tail =  [];

  /// constructor reads file contents into an array of lines
  /// defaultContent is used if file does not exist
  EditableFile(String path, [List<String> defaultContent = const []]) {
    _path = path;
    _name = p.basename(path);
    File file = File(path);
    if (file.existsSync()) {
      _lines = file.readAsLinesSync();
    } else {
      _lines = List.from(defaultContent);
    }
  }

  bool get exists {
    File file = File(_path);
    return file.existsSync();
  }

  List<String> get head {
    return _head;
  }

  void set head(List<String> newLines) {
    _head.clear();
    _head.addAll(newLines);
  }
  List<String> get lines {
    return _lines;
  }

  void set lines(List<String> newLines) {
    _lines.clear();
    _lines.addAll(newLines);
  }

  List<String> get tail {
    return _tail;
  }

  void set tail(List<String> newLines) {
    _tail.clear();
    _tail.addAll(newLines);
  }

  List<String> get content {
    return new List.from(_head)..addAll(_lines)..addAll(_tail);
  }

  void dump() {
    console.dump('''
================================================================
================================================================
================================================================
==== path($_path) name($_name)
================================================================ 
================================================================
================================================================
  ${content.join('\n  ')}
    ''');
  }

  void backup([String? filename]) {
    final fn = filename != null ? filename : _path, bak = '${fn}.bak';
    print('EditableFile backup (copy $fn -> $bak)');

    File file = File(fn);
    file.copySync(bak);
  }

  void write([String? filename, makeBackup = true]) {
    final fn = filename != null ? filename : _path;
    if (makeBackup) {
      backup(fn);
    }
    print('EditableFile  write $fn');
    File file = File(fn);
    file.writeAsString(content.join('\n'));
  }
}
