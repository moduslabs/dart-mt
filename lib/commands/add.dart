import 'dart:io';
import 'package:mt/application.dart';
import 'package:mt/mtcommand.dart';
/*import 'package:mt/console.dart';*/
/*import 'package:mt/editor.dart';*/
/*import 'package:mt/license.dart';*/

// create CHANGELOG.md
// create mt.yaml
// create pubspec.yaml
// create LICENSE

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

class AddCommand extends MTCommand {
  final name = 'add';
  final description = 'Add package/library/program/application repo as part of this monorepo';
  String invocation = 'add -d description -e executable_name name';

  String type = 'program';
  String desc = '';
  String executable = '';
  String license = 'MIT';
  bool global = false;
  bool local = false;

  AddCommand() {
    argParser.addOption('description',
        abbr: 'd', help: 'Description of project');
    argParser.addOption('executable',
        abbr: 'e', help: 'Name of executable - use with pub global activate');
    argParser.addFlag('global', help: 'Update global options values');
    argParser.addFlag('local', help: 'Update local options values');
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
    argParser.addOption('type',
        abbr: 't',
        allowed: [
          'monorepo', // a monorepo
          'program', // cli program
          'library', // package/library
          'application', // ios and/or android application
        ],
        defaultsTo: 'monorepo');
  }

/*
  _writePubspecYaml(String name) {
    final f = File('pubspec.yaml');
    if (f.existsSync()) {
      final answer =
          console.confirm('*** pubspec.yaml exists, overwrite it (y/N): ');
      if (!answer) {
        console.warn('Skipping pubspec.yaml');
        return;
      }
    }
    warn('Writing pubspec.yaml');
    f.writeAsStringSync([
      '#',
      '### pubspec for $name',
      '#',
      '',
      'version: 0.0.0',
      'description: >-',
      '  $desc',
      '',
      'environment:',
      "  sdk: '>=2.12.0 <3.0.0'",
      '',
    ].join('\n'));
  }

  _writeLicense(String name) {
    final f = File('LICENSE');
    if (f.existsSync()) {
      final answer =
          console.confirm('*** LICENSE exists, overwrite it (y/N): ');
      if (!answer) {
        console.warn('  Skipping LICENSE');
        return;
      }
    }
    final l = License(name, dryRun, verbose);
    l.setLicense(license);
    l.dump();
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

    if (mt_yaml.getValue('type') == 'program') {
      return exists('mt.yaml') &&
          exists('CHANGELOG.md') &&
          exists('pubspec.yaml') &&
          exists('LICENSE') &&
          exists('bin');
    } else {
      return exists('mt.yaml') &&
          exists('CHANGELOG.md') &&
          exists('pubspec.yaml') &&
          exists('LICENSE');
    }
  }
*/
  Future<void> exec() async {
    license = argResults?['license'] ?? 'MIT';
    type = argResults?['type'];
    global = argResults?['global'];
    local = argResults?['local'];

    final options = app.mtconfig.options;
/*    if (type != null) {*/
      options['type'] = type;
/*    }*/
    options['local'] = local;
    options['global'] = global;

    mt_yaml.query(options);
    mt_yaml.dump();
    exit(1);
    /*
    final name = _dir;
    if (_initialized) {
      if (mt_yaml.license != license) {
        final answer = console.confirm(
            '--- new license type ($license) specified (was ${mt_yaml.license}. Overwrite it (y/N): ');
        if (answer) {
          _writeLicense(name);
        }
      }
      final answer = console.confirm(
          '--- Looks like this directory is already initialized.  Proceed anyway? (y/N): ');
      if (!answer) {
        abort('No files modified');
      }
    }
    desc = argResults?['description'] ?? '';
    if (desc.length < 1) {
      desc = await Editor().edit();
    }

    if (desc.length < 1) {
      abort('no description argument!');
    }

    log('Addializing directory...');
//    _writePubspecYaml(name);
    _writeLicense(name);
    */
  }
}
