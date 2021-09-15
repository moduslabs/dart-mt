import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:pub_api_client/pub_api_client.dart';
import 'package:mt/application.dart';
import 'package:mt/mtcommand.dart';
import 'package:mt/pubspec_yaml.dart';
import 'package:mt/console.dart';

///
/// PackageSubCommand
///
/// Abstract base class for our subcommands.  There is a lot of common
/// functionality so we implement that here.  We also provide some handy
/// support methods.
///
abstract class PackageSubCommand extends MTCommand {
  late final bool _recurse;
  late final bool _local;
  late final List<String> packageNames;
  late final String? _packageDir;
  final pub_dev = PubClient();
  final packageInfos = {};

  ///
  /// bool directoryEntryExists = exists(fn);
  ///
  /// Returns true if the fn exists within the filesystem.
  ///
  bool exists(String fn) {
    File f = File(fn);
    Directory d = Directory(fn);
    return f.existsSync() || d.existsSync();
  }

  ///
  /// bool exists = await packageExists(packageName);
  ///
  /// Tests to see if the specified package exists, either as sources
  /// within the monorepo's packages directory or, if the --local command line
  /// flag is not set, look up package on pub.dev.
  ///
  /// We build a packageInfos hash map of the information retrieved from
  /// pub.dev.
  ///
  Future<bool> packageExists(String packageName) async {
    // we can always check the package directory, for local or pub.dev usage
    if (exists('$_packageDir/$packageName')) {
      return true;
    }
    if (!_local) {
      // check on pub.dev
      try {
        final info = await pub_dev.packageInfo(packageName);
        packageInfos[packageName] = info;
        return true;
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  ///
  /// abort(message);
  ///
  /// app.abort() method helper - prints *** message and calls app.abort();
  ///
  void abort(message) {
    app.abort('*** $message');
  }

  ///
  /// error(message);
  ///
  /// app.error() method helper - prints *** message and calls app.error();
  ///
  void error(message) {
    console.error('*** $message');
  }

  ///
  /// PackageSubCommand constructor.
  ///
  /// Adds common command line switches and options to the SubCOmmand.
  ///
  PackageSubCommand() : super() {
    argParser.addOption('packages',
        abbr: 'p',
        defaultsTo: null,
        help:
            'NAME of local package sources directory. Looks from project root down until NAME is found.\n' +
                'Default is to try to deduce the location.');
    argParser.addFlag('local',
        abbr: 'l',
        defaultsTo: null,
        help: 'Only look for monorepo local packages.  Do NOT search pub.dev.');
    argParser.addFlag('recurse',
        abbr: 'r',
        defaultsTo: false,
        help:
            'Perform $name recursively from directory down. Defaults to current directory.');
  }

  ///
  /// _locatePackageDir();
  ///
  /// recursively look for dirName starting at path
  ///
  bool _locatePackageDir(String path, String dirName) {
    final dir = Directory(path);
    final dirList = dir.listSync();
    for (FileSystemEntity f in dirList) {
      if (f is Directory) {
        if (f.path.indexOf(dirName) != -1) {
          _packageDir = '$path/$dirName';
          return true;
        }
        if (_locatePackageDir(f.path, dirName)) {
          return true;
        }
      }
    }
    return false;
  }

  ///
  /// _findPackageDir();
  ///
  /// If package directory name (NOT PATH) is specified on the command line,
  /// validate it and use that.  Otherwise, try to locate a suitable packages
  /// directory within the monorepo.
  ///
  bool _findPackageDir() {
    var pkgs = argResults?['packages'];
    if (pkgs != null) {
      if (pkgs.contains('.') || pkgs.contains('/')) {
        abort('Invalid packages directory name $pkgs.');
      }
      _packageDir = p.canonicalize(p.join(app.root, pkgs));
      return true;
    }
    return _locatePackageDir(app.root, 'pkg') ||
        _locatePackageDir(app.root, 'packages');
  }

  ///
  /// cd(path);
  ///
  /// change directory to path.
  ///
  cd(path) {
    Directory.current = path;
  }

  ///
  /// String currentDirectory = pwd();
  ///
  /// Return current directory as a string
  ///
  String pwd() {
    return Directory.current.path;
  }

  ///
  /// _op(String path, String packageName);
  ///
  /// Prepare Pubspec for path and call the child process' op() method.
  ///
  Future<int> _op(String path, String packageName) async {
    final ignore = mt_yaml.getValue('ignore') ?? ['.git', '.dart_tool'];
    final base = p.basename(path);
    final ndx = ignore.indexOf(base);

    if (ndx > -1) {
      // log('---> ignoring $path - in ignore list');
      return 0;
    }

    Pubspec spec = Pubspec(path);
    if (spec.dirty) {
      // log('---> ignoring $path - no pubspec.yaml');
      return 0;
    }
    return await op(path, packageName, spec);
  }

  ///
  /// recurseOp(String path, String packageName);
  ///
  /// Recursively call _op().
  ///
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
          if (result != 0) {
            return result;
          }
        }
      }
    }
    return 0;
  }

  ///
  /// run();
  ///
  /// Overrides MTCommand's run().  Calls it first, then processes command
  /// line arguments, finds the packages directory, and either recursively
  /// call _op() for each package specified on the command line, OR, calls
  /// _op() directly if the -r flag is not specified.
  ///
  @override
  Future<void> run() async {
    await super.run();
    _recurse = argResults?['recurse'] ?? false;
    _local = argResults?['local'] ?? false;

    if (rest.length < 1) {
      console.error('\n*** Error: one or more package names are required.\n');
      printUsage();
    }

    if (!_recurse && !exists('pubspec.yaml')) {
      abort('No pubspec.yaml found in current directory.');
    }

    // find packages directory
    if (!_findPackageDir()) {
      _packageDir = null;
    }

    if (verbose) {
      print('  Using local package directory: ${_packageDir}\n');
    }

    packageNames = rest;

    if (!_recurse) {
      if (!exists('pubspec.yaml')) {
        abort('No pubspec.yaml in current directory.');
      }
    }

    bool ok = true;
    for (final pn in packageNames) {
      final e = await packageExists(pn);
      if (!e) {
        ok = false;
        if (_local) {
          error('Package $pn not found in monorepo.');
        } else {
          error('Package $pn not found in monorepo or on pub.dev.');
        }
      }
    }
    if (!ok) {
      print('');
      abort('Aborting due to above errors. No files changed. ***');
    }

    final cwd = pwd();
    for (final pn in packageNames) {
      if (_recurse) {
        await recurseOp(cwd, pn);
      } else {
        print('_op $_packageDir $cwd $pn');
        await _op(cwd, pn);
      }
    }
    print('done');
  }

  ///
  /// await writeSpec(Pubspec spec, String path);
  ///
  /// if dryRun, prints message and returns, skipping the write
  /// otherwise, writes the pubspec.yaml and if verbose prints notice file was
  /// written.
  ///
  Future<void> writeSpec(Pubspec spec, String path) async {
    if (dryRun) {
      print('  --> Dry Run, skipped writing $path/pubspec.yaml');
      if (verbose) {
        spec.dump();
        print('');
        print('');
      }
    } else {
      await spec.writeYaml('$path/pubspec.yaml');
      if (verbose) {
        print('  --> Wrote $path/pubspec.yaml');
      }
    }
  }

  ///
  ///  exec();
  ///
  /// We must provide this method because the base class is abstract.  The base
  /// class' run() method will call this, but we don't care to execute any
  /// code here.  We do our work in the overridden run() method.
  ///
  Future<void> exec() async {}

  /// overridden in child classes to perform the operation!
  Future<int> op(String path, String packageName, Pubspec spec);
}

///
/// package add
///
class PackageAddCommand extends PackageSubCommand {
  final name = 'add';
  final description =
      'Add package(s) to dependencies in pubspec.yaml. The packages must exist.';
  String invocation = 'package add <package name>';

  Future<int> op(String path, String packageName, Pubspec spec) async {
    if (exists('$_packageDir/$packageName')) {
      spec.setDependency(packageName, {'path': '$_packageDir/$packageName'});
    } else {
      final info = packageInfos[packageName];
      if (info == null) {
        abort('FATAL: No pub.dev info for $packageName');
      }
      final version = info.latest.version;
      spec.setDependency(packageName, '^$version');
    }
    await writeSpec(spec, path);
    return 0;
  }
}

///
/// package remove
///
class PackageRemoveCommand extends PackageSubCommand {
  final name = 'remove';
  final description = 'Remove package(s) from dependencies in pubspec.yaml.';
  String invocation = 'package remobe <package name...>';

  Future<int> op(String path, String packageName, Pubspec spec) async {
    spec.removeDependency(packageName);
    await writeSpec(spec, path);
    return 0;
  }
}

///
/// package link
///
class PackageLinkCommand extends PackageSubCommand {
  final name = 'link';
  final description =
      'Add or replace package(s) to dependencies in pubspec.yaml as link to local sources, or fix path to already existing dependency.';
  String invocation = 'package link <package name>...';

  Future<int> op(String path, String packageName, Pubspec spec) async {
    if (_packageDir == null) {
      abort(
          "Can't link because there is no packages directory specified or found.");
    }
    if (!exists('$_packageDir/$packageName')) {
      abort(
          "Can't link because there is no such package in $_packageDir/$packageName.");
    }
    final Map<String, String> link = Map<String, String>();
    link["path"] = p.relative('$_packageDir/$packageName');
    spec.setDependency(packageName, link);
    await writeSpec(spec, path);
    return 0;
  }
}

///
/// package unlink
///
class PackageUnlinkCommand extends PackageSubCommand {
  final name = 'unlink';
  final description =
      'Add or replace package(s) to dependencies withinin pubspec.yaml as link to pub.dev version.';
  String invocation = 'package unlink <package name...>';

  Future<int> op(String path, String packageName, Pubspec spec) async {
    try {
      final info = await pub_dev.packageInfo(packageName);
      final version = info.latest.version;
      final value = spec.getDependency(packageName);
      print('value $value');
      spec.setDependency(packageName, '^$version');
      await writeSpec(spec, path);
    } catch (e, stack) {
      print('exception\n$e\n$stack');
    }
    return 0;
  }
}

///
/// package
///
/// This is the hub of the package subcommands.
///
class PackageCommand extends MTCommand {
  final name = 'package';
  final description =
      'Manipulate package dependencies within pubspec.yaml dependencies, optionally recursively.';
  String invocation =
      'package <subcommand> <package names...>\n       package -r <subcommand> <package names...>';

  PackageCommand() {
    addSubcommand(PackageAddCommand());
    addSubcommand(PackageLinkCommand());
    addSubcommand(PackageUnlinkCommand());
    addSubcommand(PackageRemoveCommand());
  }

  Future<void> exec() async {
    print('EXEC!');
  }
}
