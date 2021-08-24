import 'package:mt/application.dart';
import 'package:mt/mtcommand.dart';
import 'package:mt/mtconfig.dart';

class ConfigCommand extends MTCommand {
  final name = 'config';
  final description =
      'Global and local configuration/environment variables for mt.';
  String invocation = [
    '',
    ' config --list',
    ' config [--global] --get key',
    ' config [--global] --remove [--global] key',
    ' config [--global] key value',
    '',
  ].join('\n');

  late final MTConfig mtconfig;
  // options
  var global;
  var list;
  var remove;
  var get;

  ConfigCommand() {
/*    argParser.addOption('edit',*/
/*        abbr: "e", help: "load configuration file in editor");*/
    argParser.addFlag('global',
        help:
            "Operate on global configuration file, otherwise project local one.");
    argParser.addFlag('list', abbr: 'l', help: "Print configurations");
    argParser.addFlag('get',
        abbr: 'g', help: "Get value given key as arugmnet.");
    argParser.addFlag('remove',
        abbr: 'r', help: "Remove value given key as arugmnet.");
/*    argParser.addFlag('interactive',*/
/*        abbr: 'i', help: 'Query user if key exists and would be overwritten');*/
  }

  void _setOption(k, v, global) {
    app.mtconfig.setOption(k, v, global);
  }

  void _removeOption(k, global) {}

  void _list() {
    mtconfig.dump();
  }

  Future<void> exec() async {
    mtconfig = app.mtconfig;

    global = argResults?['global'];
    list = argResults?['list'];
    remove = argResults?['remove'];
    get = argResults?['get'];

    if (list) {
      if (global) {
        abort('--global not allowed with --list');
      }
      if (remove || get) {
        abort('Only one of --get, --list, or --remove allowed.');
      }

      return _list();
    }

    var arg0 = getArgument(0), arg1 = getArgument(1);
    if (get) {
      if (remove || list) {
        abort('Only one of --get, --list, or --remove allowed.');
      }
      if (arg0 == null) {
        return _list();
      } else {
        print('$arg0: ${mtconfig.getOption(arg0)}');
        return;
      }
    }

    if (remove) {
      if (get || list) {
        abort('Only one of --get, --list, or --remove allowed.');
      }
      if (arg0 == null) {
        return invalidUsage('Missing argument');
      } else {
        mtconfig.removeOption(arg0, global);
        mtconfig.write();
        return;
      }
    }
    if (arg0 != null && arg1 != null) {
      _setOption(arg0, arg1, global);
      mtconfig.write();
    } else {
      invalidUsage("need two arguments");
    }
  }
}
