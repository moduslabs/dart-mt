/*import 'dart:io';*/
/*import 'package:mt/console.dart';*/
import 'package:mt/editable_file.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class Pubspec extends EditableFile {
  var _doc;
  var _yaml;

  late final _path;
  late final _name;

  Pubspec(String path)
      : super('$path/pubspec.yaml', [
          'name: ${p.basename(path)}',
          'version: 0.0.0',
          'description: >-',
          '  No description',
          '#repository: https://github.com/...',
          '',
          'environment:',
          "  sdk: '>=2.12.0 <3.0.0'",
          '',
          'dependencies:',
          '  path: ^1.7.0',
          '',
        ]) {
    _yaml = loadYaml(lines.join('\n')); //  as Map;
    _doc = Map.from(_yaml);
  }

  void set version(String ver) {
    _doc['version'] = ver;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].startsWith('version:')) {
        lines[i] = 'version: $ver';
        return;
      }
    }
    if (lines.length == 0) {
      lines.insert(0, 'version: $ver');
    } else {
      lines.insert(1, 'version: $ver');
    }
  }

  String get version {
    return _doc['version'];
  }

  String get name {
    return _name;
  }

  String get description {
    return _doc['description'];
  }

  Map get doc {
    return _doc;
  }

  YamlMap get yaml {
    return _yaml;
  }

//  void write([String? filename]) {
//    final fn = filename != null ? filename : _path;
//    print('pubspec write $fn');
//    return;
//    File file = File(fn);
//    file.writeAsString(lines.join('\n'));
//  }

  @override
  String toString() {
    return 'pubspec $_path/pubspec.yaml\n$lines';
  }
}
