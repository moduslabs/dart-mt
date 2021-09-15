///
/// YamlFile class
///
/// A YamlFile is an EditableFile that reads .yaml files and can dump and write as .yaml (not JSON!).
///

import 'dart:collection';
import 'package:mt/application.dart';
import 'package:mt/editable_file.dart';
import 'package:mt/console.dart';
import 'package:yaml/yaml.dart';

abstract class YamlFile extends EditableFile {
  late var doc;
  late final _yaml;

  late final _path;
  late final _filename;
  final _spaces = '                                  ';

  final keys = [];

  YamlFile(path, filename) : super('$path/$filename', []) {
    _filename = filename;
    _path = path;

    _yaml = loadYaml(lines.join('\n')) ?? {}; //  as Map;
    doc = Map.from(_yaml);
  }

  get path {
    return _path;
  }

  void setValue(String key, dynamic value) {
    if (keys.indexOf(key) == -1) {
      app.abort('*** Cannot setValue($key), it is not an allowed key');
    }
    doc[key] = value;
  }

  dynamic getValue(String key) {
    dynamic v = doc[key];
    if (v is YamlMap) {
      doc[key] = Map<String,dynamic>.from(v);
    } else if (v is YamlList) {
      doc[key] = List.from(v);
    }

    return doc[key];
  }

  void removeValue(key) {
    doc.remove(key);
  }

  _dump(dynamic yaml, indent, lines) {
    final spaces = indent > 0 ? _spaces.substring(0, indent * 2) : '';

    if (yaml is List) {
      for (final value in yaml) {
        lines.add('$spaces$value');
      }
      return;
    }
    for (final key in yaml.keys.toList()) {
      final value = yaml[key];
      if (value is bool) {
        lines.add('$spaces$key: $value');
      } else if (value is String) {
        if (value.contains('\n')) {
          final s = value.split('\n');
          final newValue = s.join('\n  ');
          lines.add("$spaces$key: |+\n  $newValue\n");
        } else if (value.contains(' ')) {
          lines.add("$spaces$key: '$value'");
        } else {
          lines.add("$spaces$key: $value");
        }
      } else if (value is int) {
        lines.add('$spaces$key: $value');
      } else if (value is YamlList || value is YamlScalar) {
        lines.add('$spaces$key: $value');
      } else if (value is List) {
        lines.add('$spaces$key: $value');
      } else if (value is YamlMap || value is Map) {
        lines.add('$spaces$key:');
        _dump(value as Map, indent + 1, lines);
      } else if (value is YamlList || value is List) {
        lines.add('$spaces$key:');
        _dump(value as List, indent + 1, lines);
      } else if (value != null) {
        lines.add('$spaces$key:');
        _dump(value.toList(), indent + 1, lines);
      }
    }
  }

  dump({dynamic yaml = false, indent = 1}) {
    if (yaml == false) {
      yaml = doc;
    }

    final lines = [];
    _dump(yaml, indent, lines);

    console.dump('''
================================================================
================================================================
================================================================
==== $_path/$_filename 
================================================================
================================================================
================================================================
${lines.join('  \n')}
  ''');
  }

  ///
  /// Write doc to file specified by fullpath
  ///
  Future<void> writeYaml([String? fullpath, backup = true]) async {
    lines.clear();
    _dump(doc, 0, lines);
    lines.add('');
    final fn = fullpath ?? '$_path/$_filename';
/*    print("writeYaml($fn) ${lines.join('\n')}");*/
    write(fn, backup);
  }
}
