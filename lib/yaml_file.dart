///
/// YamlFile class
///
/// A YamlFile is an EditableFile that reads .yaml files and can dump and write as .yaml (not JSON!).
///

import 'package:mt/application.dart';
import 'package:mt/editable_file.dart';
import 'package:mt/console.dart';
import 'package:yaml/yaml.dart';

abstract class YamlFile extends EditableFile {
  late final doc;
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
    return doc[key];
  }

  _dump(dynamic yaml, indent, lines) {
    final spaces = indent > 0 ? _spaces.substring(0, indent * 2) : '';

    for (final key in yaml.keys.toList()) {
      final value = yaml[key];
      if (value is String) {
        lines.add('$spaces$key: $value');
      } else if (value is int) {
        lines.add('$spaces$key: $value');
      } else if (value is YamlList || value is YamlScalar) {
        lines.add('$spaces$key: $value');
      } else if (value is List) {
        lines.add('$spaces$key: $value');
      } else if (value != null){
        lines.add('$spaces$key:');
        _dump(value, indent + 1, lines);
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
==== $_filename 
================================================================
================================================================
================================================================
${lines.join('  \n')}
  ''');
  }

  ///
  /// Write doc to file specified by fullpath
  ///
  writeYaml(String? fullpath, [backup = true]) {
    lines.clear();
    _dump(doc, 0, lines);
    lines.add('');
    write(fullpath ?? '$_path/$_filename', backup);
  }
}
