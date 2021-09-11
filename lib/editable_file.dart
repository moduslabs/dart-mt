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
  late final _filename;

  /// lines before _lines are _head
  final List<String> _head = [];
  final List<String> _lines = [];

  /// lines after _lines are _tail
  final List<String> _tail = [];

  String get filename {
    return _filename;
  }
  String get path {
    return _path;
  }

  bool _dirty = false;

  bool get dirty {
    return _dirty;
  }

  set dirty(bool state) {
    _dirty = state;
  }

  /// constructor reads file contents into an array of lines
  /// defaultContent is used if file does not exist
  EditableFile(String path, [List<String> defaultContent = const []]) {
    _path = path;
    _filename = p.basename(path);
    _dirty = false;
    read(path, defaultContent);
  }

  bool read(String path, [List<String> defaultContent = const []]) {
    File file = File(path);
    if (file.existsSync()) {
      _lines.addAll(file.readAsLinesSync());
    } else {
      _lines.addAll(List.from(defaultContent));
      _dirty = true;
    }
    return true;
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
==== path($_path) name($_filename)
================================================================ 
================================================================
================================================================
  ${content.join('\n  ')}
    ''');
  }

  void backup([String? filename]) {
    final fn = filename != null ? filename : _path, bak = '${fn}.bak';

    File file = File(fn);
    if (file.existsSync()) {
      file.copySync(bak);
    }
  }

  void write([String? filename, makeBackup = true]) {
    final fn = filename != null ? filename : _path;
    if (makeBackup) {
      backup(fn);
    }
    File file = File(fn);
    file.writeAsString(content.join('\n'));
  }
}
