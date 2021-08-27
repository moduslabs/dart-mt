import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mt/console.dart';
import 'package:mt/application.dart';
import 'package:mt/mt_yaml.dart';

abstract class MTCommand extends Command {
  ProjectOptions get mt_yaml {
    return app.mt_yaml;
  }

  bool get dryRun {
    return app.dryRun;
  }

  bool get verbose {
    return app.verbose;
  }

  List<String> get rest {
    return app.rest;
  }

  String? getOption(String key) {
    return argResults?[key];
  }

  bool? getFlag(String key) {
    return argResults?[key];
  }

  //
  String? getArgument(int index) {
    return (index < rest.length) ? app.rest[index] : null;
  }

  //
  // abstract
  //
  Future<void> exec();

  void abort(String? message) {
    if (message != null) {
      print(message);
    } else {
      print('*** Aborting...');
    }
    exit(1);
  }

  void invalidUsage(String? message) {
    if (message != null) {
      print(message);
    } else {
      print('*** Aborting...');
    }
    printUsage();
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

  @override
  Future<void> run() async {
    app.init(this);
    if (dryRun) {
      console.warn(" *** Note:  Dry Run - no files will be changed");
      console.warn("");
    }
    if (app.quiet == false) {
      console.bold('');
      console.bold('== mt ${app.appVersion} by Modus Create == ');
      console.bold('');
    }
    await exec();
  }
}
