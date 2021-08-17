import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:mt/console.dart';
import 'package:mt/pubspec_yaml.dart';
import 'package:mt/changelog.dart';

class Package {
  late final _pubspec;
  late final _changelog;
  late final _packageDir;
  late final _name;
  late final _dryRun;
  late final _verbose;


  bool _modified = false;

  Package(String packageDir, dryRun, verbose) {
    _packageDir = packageDir;
    _dryRun = dryRun;
    _verbose = verbose;
    _name = p.basename(packageDir);
    _pubspec = Pubspec(packageDir);

    _changelog = Changelog(packageDir, _dryRun, _verbose);
    // dump();
  }

  Changelog get changelog { return _changelog;  }

  void updateReference(String package, String version) {
    print('updateReference package($_name) dependency($package) => $version ');
    _modified = true;
  }

  void dump() {
    print('');
    print('================================================================');
    print('==== Package $_name ($_packageDir)');
    print('================================================================');
    print('  ${_pubspec.name} ${_pubspec.version}');
    print('  ${_pubspec.description}');
    // _pubspec.dump();
    // _changelog.dump();
  }

  void write() {
    if (_modified) {
      print('write package $_name');
    }
  }
}

class Packages {
  late final _packageDir;
  late final _dryRun;
  late final _verbose;

  final _packages = [];

  final List<String> search = [
    './packages', //
    './pkg', //
//    '../packages', //
//    '../pkg'
  ];

  ///
  /// _locatePackageDir
  ///
  /// recursively look for dirName starting at path
  ///
  bool _locatePackageDir(String path, String dirName) {
    final dir = Directory(path);
    final dirList = dir.listSync();
    for (FileSystemEntity f in dirList) {
      if (f is Directory) {
        // print('directory(${f.path})');
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

  bool _findPackageDir() {
    // first look for packages or pkg directory in this project or parent
    for (String path in search) {
      File f = File(path);
      if (f.existsSync() && f is Directory) {
        _packageDir = path;
        return true;
      }
    }
    return _locatePackageDir('.', 'pkg') || _locatePackageDir('.', 'packages');
//        _locatePackageDir('..', 'pkg') ||
//        _locatePackageDir('..', 'packages');
  }

  bool _findPackages() {
    if (_findPackageDir()) {
      final dir = Directory(_packageDir);
      final dirList = dir.listSync();
      for (FileSystemEntity f in dirList) {
        if (f is Directory) {
          _packages.add(Package(f.path, _dryRun, _verbose));
        }
      }
    } else {
      _packageDir = null;
      console.warn(' *** Warning: no package directory');
    }
    return true;
  }

  Packages(bool dryRun, bool verbose) {
    _dryRun = dryRun;
    _verbose = verbose;
    // print('Packages Constructor ${Directory.current}');
    _findPackages();
    print('packageDir $_packageDir');
  }

  bool get empty {
    return _packages.length < 1;
  }

  void updateReferences(String packageName, String version) {
    print('Packages updateReferences dependency($packageName) => $version ');
    for (final package in _packages) {
      package.updateReference(packageName, version);
    }
  }

  void write() {
    for (final package in _packages) {
      package.write();
    }
  }
}
