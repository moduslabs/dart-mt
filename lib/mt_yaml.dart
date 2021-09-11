// mt.yaml is a configuration file for mt, containing hints and other specifications.
///
/// valid fields in mt.yaml:
///
/// - package: <name of package> (required)
/// - type: <type of project - program, library, (flutter) application>
/// - license: <license for project - SPDC short identifier of LICENSE text>
/// - publisher: <name of company/individual/copyright holder>
/// - author: <name of programmer(s)>
/// - copyrightYear: <year or years separated by commas>
/// - entrypoint: <relative path to main() source file, if type is program>
/// - production: <steps to perform when building for production - e.g. compile, publish, nothing...>.
/// - ignore: <array of directories to ignore , such as .git, .dart_tool, etc.>.
///

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:mt/console.dart';
import 'package:mt/application.dart';
import 'package:mt/yaml_file.dart';
import 'package:mt/license.dart';
import 'package:mt/editor.dart';

class ProjectOptions extends YamlFile {
  ProjectOptions([path = '.']) : super(path, 'mt.yaml') {}

  ///
  /// Getters and setters
  ///
  List<String> get keys {
    // list of "members" of ProjectOptions instance
    return [
      'name',
      'description',
      'type',
      'license',
      'publisher',
      'author',
      'copyrightYear',
      'entrypoint',
      'production',
      'ignore'
    ];
  }

  ///
  /// Private methods to query for individual field values
  ///

  void _queryName(defaults) {
    final prompt = defaults['type'] == 'monorepo' ? 'repo name' : 'name';
    var defaultPackage = defaults['name'];
    if (defaultPackage == null) {
      final cwd = Directory.current.path; //
      defaultPackage =
          app.mtconfig.getOption('defaultPackage') ?? p.basename(cwd); //
    }

    var answer = console.prompt('$prompt ($defaultPackage): ');
    if (answer == null) {
      app.abort('*** Aborting');
    } else if (answer == '') {
      setValue('name', defaultPackage);
    } else {
      setValue('name', answer);
    }
    console.clear(-1, '$prompt: ', getValue('name'));
  }

  //
  //
  //
  Future<void> _queryDescription(defaults) async {
    var defaultDesc = defaults['description'] ?? '';
    var desc = defaultDesc == '' ? getValue('description') : defaultDesc;

    if (desc == null) {
      desc = [];
    } else if (desc.length > 0) {
      desc = desc.split('\n') ?? [];
    }

    if (defaultDesc.length < 1) {
      desc = await Editor(
              defaultText: desc == '' ? 'Enter description' : desc.join('\n'))
          .edit();
    }

    if (desc.length < 1) {
      app.abort('*** No description argument!');
    }
    final ddesc = desc.join('\n  ');
    console.clear(-2, 'description: |\n', '  $ddesc');
    setValue('description', desc);
  }

  void _queryType(defaults) {
    if (defaults['type'] != null) {
      print('type: ${defaults["type"]}');
      return;
    }

    if (defaults['type'] == 'monorepo') {
      setValue('type', 'monorepo');
      return;
    }

    final types = ['program', 'library', 'module', 'plugin', 'application'],
        defaultTypeName = defaults['type'] ?? 'program',
        defaultTypeNumber = types.indexOf(defaultTypeName);

    String? answer = console.select('type: ', types, defaultTypeNumber);
    if (answer == null) {
      app.abort('*** Aborting');
    } else {
      setValue('type', answer);
    }
  }

  void _queryLicense(defaults) {
    print('defaults $defaults');
    final licenseKeys = License.licenseTypes.keys.toList(),
        defaultLicenseName = defaults['license'] ?? 'MIT',
        defaultLicenseNumber = licenseKeys.indexOf(defaultLicenseName);

    var answer = console.select('license: ', licenseKeys,
        defaultLicenseNumber == -1 ? 0 : defaultLicenseNumber);

    if (answer == null) {
      app.abort('*** Aborting');
    } else {
      setValue('license', answer);
    }
  }

  void _queryPublisher(defaults) {
    final defaultValue = defaults["publisher"],
        printable = defaultValue != null ? ' ($defaultValue)' : '';

    final answer = console.prompt('publisher/copyright holder$printable: ');

    if (answer == null || (answer == '' && defaultValue == '')) {
      app.abort(
          '*** Aborting because  publisher is required.  Try `mt config publisher <name of publisher>` to set it permanently.');
    }

    setValue('publisher', answer == '' ? defaultValue : answer);
    console.clear(-1, 'publisher/copyright holder: ', getValue('publisher'));
  }

  void _queryAuthor(defaults) {
    final defaultValue = defaults["author"],
        printable = defaultValue != null ? ' ($defaultValue)' : '';
    var answer = console.prompt('author/authors$printable: ');
    if (answer == null) {
      app.abort('*** Aborting');
    } else if (answer == '') {
      setValue('author', defaultValue);
    } else {
      setValue('author', answer);
    }
    console.clear(-1, 'author/authors: ', getValue('author'));
  }

  void _queryCopyrightYears(defaults) {
    var d = DateTime.now();
    final defaultValue = defaults["copyrightYear"] ?? d.year,
        printable = defaultValue != null ? ' ($defaultValue)' : '';
    var answer = console.prompt('Copyright years$printable: ');
    if (answer == null) {
      app.abort('*** Aborting');
    } else if (answer == '') {
      setValue('copyrightYear', '$defaultValue');
    } else {
      setValue('copyrightYear', answer);
    }
    console.clear(-1, 'copyright years: ', getValue('copyrightYear'));
  }

  void _queryEntrypoint(defaults) {
    final path = defaults['path'];
    List<String> choices = [];
    var defaultValue = defaults["entrypoint"];
    var d = Directory('$path/bin'), entrypointPath = 'bin';
    if (defaultValue == null) {
      if (d.existsSync()) {
        for (var entity in d.listSync()) {
          if (p.extension(entity.path) == '.dart') {
            choices.add(entity.path.replaceFirst('$path/', ''));
          }
        }
      } else {
        d = Directory('$path/lib');
        entrypointPath = 'lib';
        if (d.existsSync()) {
          for (var entity in d.listSync()) {
            if (p.extension(entity.path) == '.dart') {
              choices.add(entity.path.replaceFirst('$path/', ''));
            }
          }
        }
      }
    }

    var answer;
    if (choices.length == 1) {
      defaultValue = choices[0];
    } else if (choices.length == 0 && defaultValue == null) {
      defaultValue = '${entrypointPath}/${getValue("package")}';
    }
    final printable = defaultValue != null ? ' ($defaultValue)' : '';
    if (choices.length > 1) {
      answer = console.select('entrypoint: ', choices);
    } else {
      answer = console.prompt('entrypoint$printable: ');
      choices = [];
    }

    if (answer == null) {
      app.abort('*** Aborting');
    } else if (answer == '') {
      setValue('entrypoint', defaultValue);
    } else {
      setValue('entrypoint', answer);
    }
    console.clear(choices.length - 1, 'entrypoint: ', getValue('entrypoint'));
  }

  void _queryProduction(defaults) {
    final productionKeys = ['compile', 'publish', 'nothing'],
        defaultproductionName = defaults['production'] ?? 'nothing',
        defaultproductionNumber = productionKeys.indexOf(defaultproductionName);

    var answer = console.select('production: ', productionKeys,
        defaultproductionNumber == -1 ? 0 : defaultproductionNumber);

    if (answer == null) {
      app.abort('*** Invalid answer');
    } else {
      setValue('production', answer);
    }
  }

  void _queryIgnore(defaults) {
    final defaultValue = defaults["ignore"] ?? '.git:.dart_tool';

    final answer = console
        .prompt('ignore directories, separated by ":" ($defaultValue): ');

    if (answer == null) {
      app.abort('aborted');
    } else if (answer.length > 0) {
      setValue('ignore', answer.split(':'));
    } else {
      setValue('ignore', ['.git', '.dart_tool']);
    }
    console.clear(-1, 'ignore directories: ', getValue('ignore').join(':'));
  }

  ///
  /// prompt user for each field, similar to how npm init does.
  ///
  Future<bool> query(Map<String, dynamic> defaults) async {
  if (!dirty) {

  }

    print('\nValues for mt.yaml:\n');
    _queryName(defaults);
    await _queryDescription(defaults);
    _queryType(defaults);
    _queryLicense(defaults);
    _queryPublisher(defaults);
    _queryAuthor(defaults);
    _queryCopyrightYears(defaults);
    if (getValue('type') != 'monorepo') {
      _queryEntrypoint(defaults);
      _queryProduction(defaults);
    }
    _queryIgnore(defaults);

    return true;
  }
}
