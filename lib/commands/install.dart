import 'dart:io';
import 'package:mt/mtcommand.dart';

class InstallCommand extends MTCommand {
  final name = 'install';
  final description = 'Install project as program';

  @override
  Future<int> exec() async {
    final command = 'pub';
    if (mt_yaml.getValue('type') != 'program') {
      abort('*** "type"" is not "program" in mt.yaml');
      exit(1);
    }
    if (dryRun) {
      log('would execute "pub activate --source path ."');
      return 0;
    }

    final process = await Process.start(
        '$command', //
        ['global', 'activate', '--source', 'path', '.'], //
        mode: ProcessStartMode.inheritStdio, //
        runInShell: true //
        );
    final result = await process.exitCode;
    return result;
  }
}

class UninstallCommand extends MTCommand {
  final name = 'uninstall';
  final description = 'Uninstall project as program';

  @override
  Future<int> exec() async {
    final command = 'pub';
    if (mt_yaml.getValue('type') != 'program') {
      abort('*** "type"" is not "program" in mt.yaml');
    }

    final process = await Process.start(
        '$command', //
        ['global', 'deactivate', mt_yaml.getValue('package')], //
        mode: ProcessStartMode.inheritStdio, //
        runInShell: true //
        );

    return await process.exitCode;
  }
}
