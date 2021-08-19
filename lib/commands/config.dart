import 'package:mt/mtcommand.dart';

class ConfigCommand extends MTCommand {
  final name = 'config';
  final description = 'Global configuration/environment variables for mt.';
/*  String invocation = 'config --key <key> [--value <value>]';*/

  ConfigCommand() {
    argParser.addOption('edit',
        abbr: "e", help: "load configuration file in editor");
    argParser.addFlag('global', help: "Operate on global configuration file.");
    argParser.addFlag('local',
        help: "Operate on project local configuration file.");
    argParser.addFlag('get', help: "Get value given key as arugmnet.");
    argParser.addFlag('interactive',
        abbr: 'i', help: 'Query user if key exists and would be overwritten');
  }

  Future<void> exec() async {
    print('rest ${getFlag("get")} ${getArgument(0)}');

  }
}
