import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:mt/console.dart';
import 'package:mt/mtcommand.dart';
import 'package:mt/license.dart';

/// mt.yaml is a configuration file for mt, containing hints and other specifications.
///
/// valid fields in mt.yaml:
///
/// - package: <name of package> (required)
/// - type: <type of project - program, library, (flutter) application>
/// - license: <license for project - SPDC short identifier of LICENSE text>
/// - provider: <name of company/individual/copyright holder>
/// - author: <name of programmer(s)>
/// - copyrightYear: <year or years separated by commas>
/// - entrypoint: <relative path to main() source file, if type is program>
/// - production: <steps to perform when building for production - e.g. compile>
/// - ignore: <array of directories to ignore , such as .git, .dart_tool, etc.>
///
class ProjectOptions {
  late final _yaml;
  late final _lines;
  final _spaces = '                                  ';

  ProjectOptions([path = '.']) {
    final f = File('$path/mt.yaml');
    if (f.existsSync()) {
      _lines = f.readAsStringSync();
      _yaml = Map.from(loadYaml(_lines));
    } else {
      _yaml = {};
      _lines = [];
    }
  }

  String get type {
    return _yaml['type'];
  }

  set type(String v) {
    _yaml['type'] = v;
  }

  String get package {
    return _yaml['package'];
  }

  set package(String v) {
    _yaml['package'] = v;
  }

  String get license {
    return _yaml['license'];
  }

  set license(String v) {
    _yaml['license'] = v;
  }

  // provider is copyright holder
  String get provider {
    return _yaml['provider'];
  }

  set provider(String v) {
    _yaml['provider'] = v;
  }

  String get author {
    return _yaml['author'];
  }

  set author(String v) {
    _yaml['author'] = v;
  }

  String get copyrightYear {
    var year = _yaml['copyrightYear'];
    if (year == null) {
      year = _yaml['copyrightYear'];
    }
    if (year != null) {
      return year;
    }
    var d = DateTime.now();
    return d.year as String;
  }

  set copyrightYear(String v) {
    _yaml['copyrightYear'] = v;
  }

  List<String> get ignore {
    final list = _yaml['ignore'].value ?? [];
    final List<String> ret = [];
    for (final dir in list) {
      ret.add(dir);
    }
    return ret;
  }

  set ignore(List<String> v) {
    _yaml['ignore'] = v;
  }

  ///
  /// prompt user for each field, similar to how npm init does.
  ///
  bool query() {
    final cwd = Directory.current.path, defaultPackage = p.basename(cwd);
    var answer = console.prompt('package  ($defaultPackage): ');
    if (answer == null) {
      answer = defaultPackage;
    }
    package = answer;

    answer = console.select('type: ', [
      'program',
      'library',
      'application',
    ]);
    if (answer == null) {
      MTCommand.abort('invalid answer $answer');
    } else {
      type = answer;
    }

    answer = console.select('license: ', License.licenseTypes.keys.toList());
    if (answer == null) {
      MTCommand.abort('invalid answer $answer');
    } else {
      license = answer;
    }

    answer = console.prompt('provider/copyright holder: ');
    if (answer == null) {
      MTCommand.abort('aborted');
    } else {
      provider = answer;
    }

    answer = console.prompt('author/authors: ');
    if (answer == null) {
      MTCommand.abort('aborted');
    } else {
      author = answer;
    }

    answer = console.prompt('Copyright years: ');
    if (answer == null) {
      MTCommand.abort('aborted');
    } else {
      copyrightYear = answer;
    }

    answer = console
        .prompt('ignore directories, separated by ":" (.git:.dart_tool): ');
    if (answer == null) {
      MTCommand.abort('aborted');
    } else if (answer.length > 0) {
      ignore = answer.split(':');
    } else {
      ignore = ['.git', '.dart_tool'];
    }

    return true;
  }

  _dump(dynamic yaml, indent, lines) {
    final spaces = indent > 0 ? _spaces.substring(0, indent * 2) : '';

    print('${yaml.runtimeType}');
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
