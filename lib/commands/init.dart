import 'dart:io';
import 'package:mt/application.dart';
import 'package:mt/mtcommand.dart';
import 'package:mt/console.dart';
import 'package:mt/license.dart';

// X (don't) create CHANGELOG.md
// X (don't) create pubspec.yaml
// create mt.yaml
// create LICENSE
// create .gitignore

// git init?
// docker files

// mt.yaml
// -------
// package: mt
// entrypoint: bin/mt.dart
// type: "program"
// production: "compile"
// ignore:
//   - .git
//   - .dart_tool

class InitCommand extends MTCommand {
  final name = 'init';
  final description = 'Initialize monorepo with necessary skeleton files';
  String invocation = 'init -d description';

/*  String desc = '';*/
/*  String executable = '';*/
/*  String license = 'MIT';*/
/*  bool global = false;*/
/*  bool local = false;*/

  InitCommand() {
    argParser.addOption('description',
        abbr: 'd', help: 'Description of monorepo');
    argParser.addOption('license',
        abbr: 'l',
        allowed: [
          'Apache-2.0',
          'BSD-2-Clause',
          'BSD-3-Clause',
          'GPL-2.0',
          'GPL-3.0',
          'LGPL-2.0',
          'LGPL-2.1',
          'LGPL-3.0',
          'MIT',
          'Mozilla-2.0',
          'CDDL-1.0',
          'EPL-2.0',
        ],
        defaultsTo: 'MIT');
  }

  _writeMtYaml([String name = 'mt.yaml']) {
    mt_yaml.writeYaml(name);
  }

  Future<void> _writeLicense([String name = 'LICENSE']) async {
    final l = License(name, dryRun, verbose);
    await l.setLicense(mt_yaml.getValue('license'));
    l.write(name);
  }

  /// Get optional rest parameter, which is the path where the init process is to be run.
  get _dir {
    if (argResults == null) {
      return '.';
    }
    return (rest.length > 0) ? rest[0] : '.';
  }

  /// Determine if the directory has already been initialized as a dart project.
  bool get _initialized {
    bool exists(String path) {
      final f = File(path), d = Directory(path);
      return f.existsSync() || d.existsSync();
    }

    if (mt_yaml.getValue('type') == 'monorepo') {
      return exists('mt.yaml') && exists('LICENSE');
    } else if (mt_yaml.getValue('type') == 'program') {
      return exists('mt.yaml') &&
          exists('pubspec.yaml') &&
          exists('CHANGELOG.md') &&
          exists('LICENSE');
    } else {
      return exists('mt.yaml') &&
          exists('CHANGELOG.md') &&
          exists('pubspec.yaml') &&
          exists('LICENSE');
    }
  }

  Future<void> exec() async {
    final options = app.mtconfig.options;
    options['type'] = 'monorepo';
    options['license'] = argResults?['license'] ?? 'MIT';
    options['description'] = argResults?['description'] ?? '';

    final name = _dir;
    if (_initialized) {
      if (mt_yaml.getValue('license') != options['license']) {
        final answer = console.confirm(
            '--- new license type (${mt_yaml.getValue("license")}) specified (was ${mt_yaml.getValue("license")}.  Overwrite it (y/N): ',
            yes);
        if (!answer) {
          abort('*** will not change license type.');
        }
      }

      final answer = console.confirm(
          '--- Looks like this directory is already initialized.  Proceed anyway? (y/N): ',
          yes);
      if (!answer) {
        abort('*** No files modified');
      }
    }

    await mt_yaml.query(options);

    log('Initializing directory...');
    _writeMtYaml();
    await _writeLicense('$name/LICENSE');
  }
}
