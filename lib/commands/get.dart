import 'dart:io';
/*import 'dart:io' show Platform;*/
import 'package:path/path.dart' as p;
import 'package:mt/mtcommand.dart';

class GetCommand extends MTCommand {
  final name = 'get';
  final description = 'Run pub get on directory or directories';
  bool recurse = false;

  cd(path) {
    Directory.current = path;
  }

  GetCommand() {
    argParser.addFlag('recurse',
        abbr: 'r',
        defaultsTo: false,
        help:
            'Perform pub get recursively from directory down. Defaults to current directory.');
  }

  Future<int> pubGet(String path) async {
    final f = File('./pubspec.yaml');
    if (f.existsSync()) {
      print('\n${p.current}');
      final process = await Process.start(
          'pub', //
          ['get'], //
          mode: ProcessStartMode.inheritStdio, //
          runInShell: true //
          );

      final result = await process.exitCode;

      return result;
    } else {
      log('---> skipping $path - no pubspec.yaml ($f)');
      return 0;
    }
  }

  Future<int> recurseGet(String path) async {
    final dir = Directory(path);
    final dirList = dir.listSync();
    final base = p.basename(path);
    final ignore = mt_yaml.ignore;

    // ignore directories in the mt.yaml ignore list
    if (ignore.indexOf(base) > -1) {
      log('---> ignoring $path');
      return 0;
    }

    for (FileSystemEntity f in dirList) {
      if (f is File) {
        continue;
      } else {
        var result = await recurseGet(f.path);
        if (result != 0) {
          return result;
        }
        final cwd = Directory.current;
        cd(f.path);
        result = await pubGet(path);
        cd(cwd);
        if (result != 0) {
          return result;
        }
      }
    }
    return 0;
  }

  @override
  Future<int> exec() async {
    recurse = argResults?['recurse'] ?? false;

    final dir = rest.length > 0 ? rest[0] : '.';

    if (recurse) {
      log('Performing pub get recursively, start in $dir');
      return await recurseGet(dir);
    }
    log('Performing pub get in $dir');
    return await pubGet(dir);
  }
}
