import 'dart:io';
import 'dart:convert';

class Git {
  late final _dryRun;
  late final _verbose;

  Git(bool dryRun, bool verbose) {
    _dryRun = dryRun;
    _verbose = verbose;
  }

  static String _one(array, string) {
    array.add(string.trim());
    return ('array $array, string($string)');
  }

  static Future<String> _readString(Stream input) async {
    var result = [];
    await input.transform(utf8.decoder).forEach((x) => _one(result, x));
    return result.join('');
  }

  static Future<String> root() async {
    final process = await Process.start(
        'git', //
        ['rev-parse', '--show-toplevel'],
        runInShell: true //
        );
    final result = await _readString(process.stdout);
    return result;
  }

  Future<int> commit(String message) async {
    if (_verbose) {
      if (_dryRun) {
        print('dryRun would git commit -a -m $message');
      } else {
        print('git commit -a -m $message');
      }
    }
    final process = await Process.start(
        'git', //
        ['-a', '-m', message], //
        mode: ProcessStartMode.inheritStdio, //
        runInShell: true //
        );

    final result = await process.exitCode;
    return result;
  }
}
