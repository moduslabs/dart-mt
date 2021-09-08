import 'dart:io';

class Dart {
  late final _dryRun;
  late final _verbose;

  Dart(bool dryRun, bool verbose) {
    _dryRun = dryRun;
    _verbose = verbose;
  }

  Future<int> createProgram(directory) async {
    if (_verbose) {
      if (_dryRun) {
        print('dryRun would dart create $directory');
      } else {
        print('dart create $directory');
      }
    }
    final process = await Process.start(
        'dart', //
        ['create', directory],
        runInShell: true //
        );
    final result = await process.exitCode;
    return result;
  }
}
