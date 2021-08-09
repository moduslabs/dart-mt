/*import 'dart:io';*/
import 'package:args/command_runner.dart';
import '../lib/console.dart';
//import 'package:ansicolor/ansicolor.dart';
/*import 'package:yaml/yaml.dart';*/
/*import 'package:mt/mt_yaml.dart';*/
import '../commands/bump.dart';
import '../commands/install.dart';
import '../commands/get.dart';
import '../commands/clean.dart';
import '../commands/root.dart';
import '../commands/analyze.dart';

main(List<String> args) {
/*  final mt_yaml = loadYaml(File('mt.yaml').readAsStringSync());*/
/*  final mt_yaml = ProjectOptions();*/
/*  print('mt_yaml $mt_yaml');*/
/*  // print('doc $doc');*/

//  AnsiPen pen = new AnsiPen();
//  pen
//      ..reset()
//      ..white(bg: true, bold: true)
//      ..white(bold: true)
//      ;
  console.bold('');
  console.bold(' ======================== ');
  console.bold(' == mt by Modus Create == ');
  console.bold(' ======================== ');
  console.bold('');
//  print('');
//  print(pen(" mt by Modus Create "));
//  print('');

  CommandRunner('mt', 'A tool to manage Dart monorepos')
    ..addCommand(BumpCommand())
    ..addCommand(InstallCommand())
    ..addCommand(UninstallCommand())
    ..addCommand(GetCommand())
    ..addCommand(AnalyzeCommand())
    ..addCommand(RootCommand())
    ..addCommand(CleanCommand())
    ..argParser.addOption('mode', allowed: ['debug', 'release'], defaultsTo: 'debug')
    ..argParser.addFlag('verbose',
        abbr: 'v', defaultsTo: false, help: 'Print verbose logging')
    ..argParser.addFlag('dry-run',
        abbr: 'n', defaultsTo: false, help: 'Do not update files')
    ..run(args);
}
