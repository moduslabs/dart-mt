import 'dart:io';

class Flutter {
  late final _dryRun;
  late final _verbose;

  Flutter(bool dryRun, bool verbose) {
    _dryRun = dryRun;
    _verbose = verbose;
  }

  Future<int> createApplication(String directory) async {
    if (_verbose) {
      if (_dryRun) {
        print('dryRun would flutter create -t app $directory');
      } else {
        print(' --> flutter create -t app $directory');
      }
    }

    final process = await Process.start(
        'flutter', //
        ['create', '-t', 'app', directory],
        runInShell: true //
        );
    final result = await process.exitCode;
    return result;
  }

  Future<int> createModule(String directory) async {
    if (_verbose) {
      if (_dryRun) {
        print('dryRun would flutter create -t module $directory');
      } else {
        print(' --> flutter create -t module $directory');
      }
    }

    final process = await Process.start(
        'flutter', //
        ['create', '-t', 'module', directory],
        runInShell: true //
        );
    final result = await process.exitCode;
    return result;
  }

  Future<int> createPackage(String directory) async {
    if (_verbose) {
      if (_dryRun) {
        print('dryRun would flutter create -t package $directory');
      } else {
        print(' --> flutter create -t package $directory');
      }
    }

    final process = await Process.start(
        'flutter', //
        ['create', '-t', 'package', directory],
        runInShell: true //
        );
    final result = await process.exitCode;
    return result;
  }

  Future<int> createPlugin(String directory) async {
    if (_verbose) {
      if (_dryRun) {
        print('dryRun would flutter create -t plugin $directory');
      } else {
        print(' --> flutter create -t plugin $directory');
      }
    }

    final process = await Process.start(
        'flutter', //
        ['create', '-t', 'plugin', directory],
        runInShell: true //
        );
    final result = await process.exitCode;
    return result;
  }
}
