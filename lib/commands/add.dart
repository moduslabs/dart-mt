import 'dart:io';
import 'package:mt/application.dart';
import 'package:mt/mt_yaml.dart';
import 'package:mt/license.dart';
import 'package:mt/changelog.dart';
import 'package:mt/mtcommand.dart';
import 'package:mt/console.dart';
import 'package:mt/dart.dart';
import 'package:mt/flutter.dart';
import 'package:path/path.dart' as p;

// Notes:
// create mt.yaml
// create LICENSE

// git init?
// docker files

class AddCommand extends MTCommand {
  final name = 'add';
  final description =
      'Add package/library/program/application repo as part of this monorepo';
  String invocation = 'add <directory>';

  String type = 'application';
  String desc = '';
  String executable = '';
  String license = 'MIT';

  AddCommand() {
    argParser.addOption('description',
        abbr: 'd', help: 'Description of package or program');
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
        defaultsTo: null);

    argParser.addOption('type',
        abbr: 't',
        allowed: [
          'program', // cli program
          'library', // package/library
          'module', // flutter module
          'plugin', // flutter plugin
          'application', // flutter application
        ],
        defaultsTo: 'application');
  }

  _writeLicense(String license, String name) async {
    final l = License(name, dryRun, verbose);
    await l.setLicense(license);
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
  bool _initialized(String dir, String type) {
    print('  Checking to see if ${type} ${dir}/ exists...');
    bool exists(String path) {
      final f = File('$dir/$path'), d = Directory('$dir/$path');
      final fe = f.existsSync(), de = d.existsSync();
      if (verbose && (fe || de)) {
        print('  ${f.path} exists.');
      } else {
        print('  ${f.path} does not exist.');
      }
      return fe || de;
    }

    if (type == 'program') {
      return exists('mt.yaml') && exists('pubspec.yaml');
    } else if (type == 'application') {
      return exists('mt.yaml') && exists('pubspec.yaml') && exists('lib');
    } else {
      return exists('mt.yaml') && exists('pubspec.yaml') && exists('LICENSE');
    }
  }

  Future<void> exec() async {
    // mt add
    type = argResults?['type'] ?? 'application';
    final options = app.mtconfig.options;

    options['description'] = argResults?['description'] ?? '';
    options['type'] = type;
    options['name'] = p.basename(rest[0]);

    if (app.rest.length < 1) {
      printUsage();
      abort('');
    }
    final path = app.rest[0];
    final new_mt_yaml = ProjectOptions(path);
    options['license'] = argResults?['license'] ??
        new_mt_yaml.getValue('license') ??
        options['license'] ??
        'MIT';
    options['path'] = path;

    if (_initialized(path, type)) {
      final answer = console.confirm(
          '--- Looks like this directory is already initialized.  Proceed anyway? (y/N): ',
          yes);
      if (!answer) {
        abort('*** No files modified');
      }
    }
    switch (type) {
      case 'application':
        await new Flutter(dryRun, verbose).createApplication(path);
        break;
      case 'module':
        await new Flutter(dryRun, verbose).createModule(path);
        break;
      case 'package':
        await new Flutter(dryRun, verbose).createPackage(path);
        break;
      case 'plugin':
        await new Flutter(dryRun, verbose).createPlugin(path);
        break;
      case 'program':
        await new Dart(dryRun, verbose).createProgram(path);
        break;
    }

    if (new_mt_yaml.dirty ||
        console.confirm(
            'mt.yaml exists, do you want to update its values? (y/N): ', yes)) {
      await new_mt_yaml.query(options);
      new_mt_yaml.writeYaml('$path/mt.yaml');
      if (verbose) {
        print('  Wrote $path/mt.yaml.');
      }
    }
    if (new_mt_yaml.getValue('license') != options['license']) {
      if (verbose) {
        print('  Writing new license ${options['license']}');
      }
      _writeLicense(new_mt_yaml.getValue('license'), '$path/LICENSE');
    } else {
      if (verbose) {
        print('  LICENSE ${options['license']} unchanged, not writing it.');
      }
    }
    File f = File('$path/CHANGELOG.md');
    if (!f.existsSync()) {
      Changelog c = Changelog('$path', dryRun, verbose);
      c.write();
    } else {
      if (verbose) {
        print('  CHANGELOG.md exists, not writing it');
      }
    }
  }
}
