import 'dart:io';
import 'dart:io' show Platform;
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:args/command_runner.dart';
import 'package:mt/mtconfig.dart';
import 'package:mt/mtcommand.dart';
import 'package:mt/console.dart';
import 'package:mt/mt_yaml.dart';
import 'package:mt/git.dart';

import 'package:mt/commands/bump.dart';
import 'package:mt/commands/config.dart';
import 'package:mt/commands/init.dart';
import 'package:mt/commands/add.dart';
import 'package:mt/commands//install.dart';
import 'package:mt/commands/get.dart';
import 'package:mt/commands/clean.dart';
import 'package:mt/commands/root.dart';
import 'package:mt/commands/analyze.dart';

final Application app = Application();

class Application {
  late final bool verbose;
  late final bool dryRun;
  late final bool yes;
  late final bool quiet;
  late final String root;
  late final List<String> rest;

  late final List<String> _args;
  late final MTConfig mtconfig;
  late final ProjectOptions mt_yaml;
  late final String appVersion;

  get args {
    return _args;
  }

  String? getArgument(int index, [defaultValue = null]) {
    return _args.length > index ? _args[index] : defaultValue;
  }

  String? getOption(String key) {
    return mtconfig.getOption(key);
  }

  void abort(String? message) {
    if (message != null) {
      console.error(message);
    } else {
      print('*** Aborting...');
    }
    exit(1);
  }

  ///
  /// Print a string via console.success if verbose flag is set.
  ///
  void success(String s) {
    if (verbose) {
      console.success(s);
    }
  }

  ///
  /// Print a string via console.warn if verbose flag is set.
  ///
  void warn(String s) {
    if (verbose) {
      console.warn(s);
    }
  }

  ///
  /// Print a string via console.out if verbose flag is set.
  ///
  void error(String s) {
    if (verbose) {
      console.error(s);
    }
  }

  ///
  /// Print a string via console.log if verbose flag is set.
  ///
  void log(String s) {
    if (verbose) {
      console.log(s);
    }
  }

  Application() {}

  bool _quiet(MTCommand c) {
    return c is RootCommand || (c.globalResults?['quiet'] ?? true);
  }

  Future<void> init(MTCommand c) async {
    final pubspec_path = '${p.dirname(Platform.script.toFilePath())}/../pubspec.yaml';
    File f = File(pubspec_path);
    Map pubspec_yaml = loadYaml(f.readAsStringSync());
    appVersion = pubspec_yaml['version'];

    dryRun = c.globalResults?['dry-run'] ?? false;
    verbose = c.globalResults?['verbose'] ?? false;
    quiet = _quiet(c); // c.globalResults?["quiet"];
    yes = c.globalResults?["yes"];
    rest = c.argResults?.rest as List<String>;
    root = await Git.root();

    mtconfig = MTConfig();
    mt_yaml = ProjectOptions('.');
  }

  ///
  /// run() is the start of the program.
  ///
  void run(List<String> args) async {
    _args = args;
    final r = CommandRunner('mt', 'A tool to manage Dart monorepos')
      ..addCommand(ConfigCommand())
      ..addCommand(InitCommand())
      ..addCommand(AddCommand())
      ..addCommand(BumpCommand())
      ..addCommand(InstallCommand())
      ..addCommand(UninstallCommand())
      ..addCommand(GetCommand())
      ..addCommand(AnalyzeCommand())
      ..addCommand(RootCommand())
      ..addCommand(CleanCommand())
      ..argParser
          .addOption('mode', allowed: ['debug', 'release'], defaultsTo: 'debug')
      ..argParser.addFlag('verbose',
          abbr: 'v', defaultsTo: false, help: 'Print verbose logging')
      ..argParser.addFlag('dry-run',
          abbr: 'n', defaultsTo: false, help: 'Do not update files')
      ..argParser
          .addFlag('yes', abbr: 'y', help: 'answer Y(es) to all questions')
      ..argParser.addFlag('quiet',
          abbr: 'q',
          defaultsTo: false,
          help: 'Hide mt banner (defaults to false)');
    try {
      await r.run(app.args);
    } on UsageException catch (_) {}
  }
}
