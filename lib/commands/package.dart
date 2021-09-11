import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:mt/application.dart';
import 'package:mt/mtcommand.dart';
import 'package:mt/pubspec_yaml.dart';
import 'package:mt/console.dart';

abstract class PackageSubCommand extends MTCommand {
  late final List<String> packageNames;
  late final String? packageDir;
  PackageSubCommand() : super() {}

  ///
  /// _locatePackageDir
  ///
  /// recursively look for dirName starting at path
  ///
  bool _locatePackageDir(String path, String dirName) {
    if (path.endsWith('.git')) {
      return false;
    }
    final dir = Directory(path);
    final dirList = dir.listSync();
    for (FileSystemEntity f in dirList) {
      if (f is Directory) {
        // print('directory(${f.path})');
        if (f.path.indexOf(dirName) != -1) {
          packageDir = '$path/$dirName';
          return true;
        }
        if (_locatePackageDir(f.path, dirName)) {
          return true;
        }
      }
    }
    return false;
  }

  bool _findPackageDir() {
    var pkgs = parent?.argResults?['packages'];
    if (pkgs != null) {
      packageDir = pkgs;
      return true;
    }
    return _locatePackageDir(app.root, 'pkg') ||
        _locatePackageDir(app.root, 'packages');
  }

  cd(path) {
    Directory.current = path;
  }

  String pwd() {
    return Directory.current.path;
  }

  Future<int> _op(String path, String packageName) async {
    final ignore = mt_yaml.getValue('ignore') ?? ['.git', '.dart_tool'];
    final base = p.basename(path);
    final ndx = ignore.indexOf(base);

    if (ndx > -1) {
      log('---> ignoring $path - in ignore list');
      return 0;
    }
    print("load pubspec($path)");
    Pubspec spec = Pubspec(path);
    if (spec.dirty) {
      log('---> ignoring $path - no pubspec.yaml');
      return 0;
    }
    return await op(path, packageName, spec);
  }

  Future<int> recurseOp(String path, String packageName) async {
    final dir = Directory(path);
    final dirList = dir.listSync();
    final ignore = mt_yaml.getValue('ignore') ?? ['.git', '.dart_tool'];
    final base = p.basename(path);
    final ndx = ignore.indexOf(base);

    // ignore directories in the mt.yaml ignore list
    if (ndx > -1) {
/*      print('---> ignoring $path');*/
      return 0;
    } else {
      for (FileSystemEntity f in dirList) {
        if (f is File) {
          continue;
        } else {
          var result = await recurseOp(f.path, packageName);
          if (result != 0) {
            return result;
          }
          final cwd = pwd();
          cd(f.path);
          result = await _op(Directory.current.path, packageName);
          cd(cwd);
/*          if (result != 0) {*/
/*            return result;*/
/*          }*/
        }
      }
    }
    return 0;
  }

  @override
  Future<void> run() async {
    await super.run();
    final dir = '.';
    if (rest.length < 1) {
      console.error('\n*** Error: one or more package names are required.\n');
      printUsage();
    }

    // find packages directory
    if (!_findPackageDir()) {
      packageDir = null;
    }

    if (verbose) {
      print('  packageDir: ${packageDir}');
    }

    packageNames = rest;
    final cwd = pwd();
    for (final pn in packageNames) {
      recurseOp(cwd, pn);
      break;
    }
  }

  Future<void> exec() async {}

  /// overridden in child classes to perform the operation!
  Future<int> op(String path, String packageName, Pubspec spec);
}

class PackageAddCommand extends PackageSubCommand {
  final name = 'add';
  final description = 'Add package(s) to dependencies in pubspec.yaml.';
  String invocation = 'package add <package name>';

  Future<int> op(String path, String packageName, Pubspec spec) async {
    print('  add($path, $packageName)');
    spec.setDependency(packageName, { 'path': '/pkg/$packageName' });
    print('');
    print('spec $spec');
    print('');
    spec.writeYaml();
    return 0;
  }
}

class PackageLinkCommand extends PackageSubCommand {
  final name = 'link';
  final description =
      'Add or replace package(s) to dependencies in pubspec.yaml as link to local sources, or fix path to already existing dependency.';
  String invocation = 'package link <package name>...';

  Future<int> op(String path, String packageName, Pubspec spec) async {
    print('  link($packageName)');
    return 0;
  }
}

class PackageUnlinkCommand extends PackageSubCommand {
  final name = 'unlink';
  final description =
      'Add or replace package(s) to dependencies withinin pubspec.yaml as link to pub.dev version.';
  String invocation = 'package unlink <package name...>';

  Future<int> op(String path, String packageName, Pubspec spec) async {
    print('  unlink($packageName)');
    return 0;
  }
}

class PackageRemoveCommand extends PackageSubCommand {
  final name = 'remove';
  final description = 'Remove package(s) from dependencies in pubspec.yaml.';
  String invocation = 'package remobe <package name...>';

  Future<int> op(String path, String packageName, Pubspec spec) async {
    print('  remove($packageName)');
    return 0;
  }
}

class PackageCommand extends MTCommand {
  final name = 'package';
  final description =
      'Manipulate package dependencies within pubspec.yaml dependencies, optionally recursively.';
  String invocation =
      'package <subcommand> <package names...>\n       package -r <subcommand> <package names...>';

  PackageCommand() {
    argParser.addOption('packages',
        abbr: 'p',
        defaultsTo: null,
        help:
            'Location of local package sources. Default is to try to deduce the location.');
    addSubcommand(PackageAddCommand());
    addSubcommand(PackageLinkCommand());
    addSubcommand(PackageUnlinkCommand());
    addSubcommand(PackageRemoveCommand());
  }

  Future<void> exec() async {
    print('EXEC!');
  }
}
