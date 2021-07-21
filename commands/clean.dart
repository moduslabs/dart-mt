import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:mt/console.dart';
import 'package:mt/mtcommand.dart';

class CleanCommand extends MTCommand {
  final name = 'clean';
  final description = 'Clean .bak files';

  bool verbose = false;
  bool dryRun = false;
  bool recurse = false;

  CleanCommand() {
    argParser.addFlag('recurse',
        abbr: 'r',
        defaultsTo: false,
        help:
            'Perform pub get recursively from directory down. Defaults to current directory.');
    argParser.addFlag('bak',
        abbr: 'b', defaultsTo: true, help: 'Remove .bak files');
  }

  bool _cleanDirectoryBak(String path) {
    final base = p.basename(path);
    final ignore = mt_yaml.ignore;

    if (ignore.indexOf(base) > -1) {
      if (verbose) {
        console.warn(' *** recurse: ignoring $path');
      }
      return false;
    }

    final dir = Directory(path);
    final dirList = dir.listSync();

    for (FileSystemEntity f in dirList) {
      if (f is File) {
        if (f.path.endsWith('.bak')) {
          if (!dryRun) {
            f.deleteSync();
          }
          if (verbose) {
            console.success('remove ${f.path}');
          }
        }
      }
    }
    return true;
  }

  _recurseCleanBak(String path) {
    final dir = Directory(path);
    final dirList = dir.listSync();
    for (FileSystemEntity f in dirList) {
      if (f is Directory) {
        if (_cleanDirectoryBak(f.path)) {
          _recurseCleanBak(f.path);
        }
      }
    }
    _cleanDirectoryBak(path);
  }

  @override
  Future<void> run() async {
    dryRun = globalResults?['dry-run'] ?? false;
    verbose = globalResults?['verbose'] ?? false;
    recurse = argResults?['recurse'] ?? false;

    final rest = argResults?.rest as List<String>;
    final path = rest.length > 0 ? rest[0] : '.';

    if (argResults?["recurse"]) {
      _recurseCleanBak(path);
    } else {
      _cleanDirectoryBak(path);
    }
  }
}
