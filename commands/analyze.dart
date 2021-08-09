import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:mt/mtcommand.dart';
import 'package:mt/console.dart';

class AnalyzeCommand extends MTCommand {
  final name = 'analyze';
  final description = 'Run dart analyze on current project';

  bool verbose = false;
  bool dryRun = false;
  bool recurse = false;

  AnalyzeCommand() {
    argParser.addFlag('recurse',
        abbr: 'r',
        defaultsTo: false,
        help:
            'Perform analyze recursively from directory down. Defaults to current directory.');
  }

  Future<bool> _analyzeDirectory(String path) async {
    final base = p.basename(path);
    final ignore = mt_yaml.ignore;

    if (ignore.indexOf(base) > -1) {
      if (verbose) {
        console.warn(' *** recurse: ignoring $path');
      }
      return false;
    }

    File f = File('$path/pubspec.yaml');
    if (f.existsSync()) {
      final process = await Process.start(
          'dart', //
          ['analyze'], //
          mode: ProcessStartMode.inheritStdio, //
          runInShell: true //
          );
      final result = await process.exitCode;
      return result == 0;
    }
    else {
      if (verbose) {
      console.warn(' *** recurse: ignoing $path (no pubspec.yaml)');
      }
    }
    return true;
  }

  _recurseAnalyze(String path) async {
    final dir = Directory(path);
    final dirList = dir.listSync();
    for (FileSystemEntity f in dirList) {
      if (f is Directory) {
        if (await _analyzeDirectory(f.path)) {
          _recurseAnalyze(f.path);
        }
      }
    }
    _analyzeDirectory(path);
  }

  @override
  Future<int> run() async {
    dryRun = globalResults?['dry-run'] ?? false;
    verbose = globalResults?['verbose'] ?? false;
    recurse = argResults?['recurse'] ?? false;

    final rest = argResults?.rest as List<String>;
    final path = rest.length > 0 ? rest[0] : '.';

    if (recurse) {
      _recurseAnalyze(path);
    } else {
      _analyzeDirectory(path);
    }
/*    String result = await Git.root();*/
/*    print(result);*/
    return 0;
/*    return result;*/
  }
}
