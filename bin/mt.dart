import 'package:args/command_runner.dart';
import '../commands/bump.dart';
import '../commands/init.dart';
import '../commands/install.dart';
import '../commands/get.dart';
import '../commands/clean.dart';
import '../commands/root.dart';
import '../commands/analyze.dart';

main(List<String> args) async {
  final r = CommandRunner('mt', 'A tool to manage Dart monorepos')
    ..addCommand(InitCommand())
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
        .addOption('yes', abbr: 'y', help: 'answer Y(es) to all questions')
    ..argParser.addFlag('quiet',
        abbr: 'q',
        defaultsTo: false,
        help: 'Hide mt banner (defaults to false)');
  try {
    await r.run(args);
  } on UsageException catch (_) {}
}
