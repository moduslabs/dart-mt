import 'dart:io';
import 'package:mt/mtcommand.dart';
import 'package:mt/console.dart';
import 'package:mt/editor.dart';
import 'package:mt/license.dart';

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

class InitCommand extends MTCommand {
  final name = 'init';
  final description = 'Initialize project with necessary skeleton files';
  String invocation = 'init -d description -e executable_name name';

  bool verbose = false;
  bool dryRun = false;
  String type = 'library';
  String desc = '';
  String executable = '';
  String license = 'MIT';

  InitCommand() {
    argParser.addOption('description',
        abbr: 'd', help: 'Description (required)');
    argParser.addOption('executable',
        abbr: 'e', help: 'Name of executable - use with pub global activate');
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
          'program', // cli program
          'library', // package/library
          'application', // ios and/or android application
        ],
        defaultsTo: 'program');
  }

  _writePubspecYaml(String name) {
    final f = File('pubspec.yaml');
    if (f.existsSync()) {
      final answer =
          console.yesOrNo('*** pubspec.yaml exists, overwrite it (y/N): ');
      if (!answer) {
        console.warn('Skipping pubspec.yaml');
        return;
      }
    }
    if (verbose) {
      console.warn('Writing pubspec.yaml');
    }
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
          console.yesOrNo('*** LICENSE exists, overwrite it (y/N): ');
      if (!answer) {
        console.warn('  Skipping yaml');
        return;
      }
    }
    final l = License(name, type, dryRun, verbose);
    l.setLicense(license);
    l.dump();
  }

  get _dir {
    if (argResults == null) {
      return '.';
    }
    final r = argResults?.rest ?? [];
    if (r.length > 0) {
      return r[0];
    }
    return '.';
  }

  bool _exists(String path) {
    final f = File(path), d = Directory(path);
    return f.existsSync() || d.existsSync();
  }

  bool get _initialized {
    if (mt_yaml.type == 'program') {
      return _exists('mt.yaml') &&
          _exists('CHANGELOG.md') &&
          _exists('pubspec.yaml') &&
          _exists('LICENSE') &&
          _exists('bin');
    } else {
      return _exists('mt.yaml') &&
          _exists('CHANGELOG.md') &&
          _exists('pubspec.yaml') &&
          _exists('LICENSE');
    }
  }

  Future<void> exec() async {
    dryRun = globalResults?['dry-run'] ?? false;
    verbose = globalResults?['verbose'] ?? false;
    license = argResults?['license'] ?? 'program';
    final name = _dir;

    if (_initialized) {
      if (mt_yaml.license != license) {
        final answer = console.yesOrNo(
            '--- new license type ($license) specified (was ${mt_yaml.license}. Overwrite it (y/N): ');
        if (answer) {
          _writeLicense(name);
        }
      }
      final answer = console.yesOrNo(
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
      print('*** Aborted - no description argument');
      exit(1);
    }

/*    _writePubspecYaml(name);*/
    _writeLicense(name);
    if (verbose) {
      print('Initializing directory...');
    }
  }
}
