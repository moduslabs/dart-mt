import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mt/console.dart';
import 'package:mt/mt_yaml.dart';

abstract class MTCommand extends Command {
  final _mt_yaml = ProjectOptions('.');
  late final bool dryRun;

  MTCommand() {}

  ProjectOptions get mt_yaml {
    return _mt_yaml;
  }

  Future<void> exec();

  void abort(String? message) {
    if (message != null) {
      print(message);
    } else {
      print('*** Aborting...');
    }
    exit(1);
  }

  @override
  Future<void> run() async {
    final quiet = globalResults?["quiet"];

    if (quiet == false || quiet == null) {
      console.bold('');
      console.bold(' ======================== ');
      console.bold(' == mt by Modus Create == ');
      console.bold(' ======================== ');
      console.bold('');
    }
    await exec();
  }
/*  Future<List<String>> _loadFile(String filename) async {*/
/*    File file = File(filename);*/
/*    return await file.readAsLines();*/
/*  }*/
}
