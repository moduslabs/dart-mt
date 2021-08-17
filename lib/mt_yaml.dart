import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:mt/console.dart';

class ProjectOptions {
  late final _yaml;
  late final _lines;
  final _spaces = '                                  ';

  ProjectOptions([path = '.']) {
    final f = File('$path/mt.yaml');
    if (f.existsSync()) {
      _lines = f.readAsStringSync();
      _yaml = loadYaml(_lines);
    } else {
      _yaml = {};
      _lines = [];
    }
  }

  String get type {
    return _yaml['type'];
  }

  String get package {
    return _yaml['package'];
  }

  String get license {
    return _yaml['license'];
  }

  // provider is copyright holder
  String get provider {
    return _yaml['provider'];
  }

  String get author {
    return _yaml['author'];
  }

  String get copyrightYears {
    var year = _yaml['copyrightYears'];
    if (year == null) {
      year = _yaml['copyrightYear'];
    }
    if (year != null) {
      return year;
    }
    var d = DateTime.now();
    return d.year as String;
  }

  List<String> get ignore {
    final list = _yaml['ignore'].value ?? [];
    final List<String> ret = [];
    for (final dir in list) {
      ret.add(dir);
    }
    return ret;
/*    return ret as List<String>;*/
  }

  _dump(dynamic yaml, indent, lines) {
    final spaces = indent > 0 ? _spaces.substring(0, indent * 2) : '';
    for (final key in yaml.keys) {
      final value = yaml[key];
      if (value is String) {
        lines.add('$spaces$key: $value');
      } else if (value is YamlList || value is YamlScalar) {
        lines.add('$spaces$key: $value');
      } else {
        lines.add('$spaces$key:');
        _dump(value, indent + 1, lines);
      }
    }
  }

  dump({dynamic yaml = false, indent = 1}) {
    if (yaml == false) {
      yaml = _yaml;
    }

    final lines = [];
    _dump(yaml, indent, lines);

    console.dump('''
================================================================
================================================================
================================================================
==== mt.yaml (parsed to object)
================================================================
================================================================
================================================================
${lines.join('  \n')}
  ''');
  }
}
