import 'dart:io';
/*import 'package:yaml/yaml.dart';*/
import 'package:mt/console.dart';
import 'package:version/version.dart';
import 'package:mt/mtcommand.dart';
import 'package:mt/pubspec_yaml.dart';
import 'package:mt/changelog.dart';
import 'package:mt/packages.dart';
import 'package:mt/editor.dart';

class BumpCommand extends MTCommand {
  final name = 'bump';
  final description = 'bump version numbers';

  BumpCommand() {
    argParser.addOption('type',
        abbr: 't',
        allowed: ['major', 'minor', 'patch', 'prerelease'],
        defaultsTo: 'patch');
    argParser.addOption('message',
        abbr: 'm', help: 'Message to add to CHANGELOG and for git commit');
    argParser.addFlag('fix',
        abbr: 'f',
        defaultsTo: false,
        help:
            'Update monorepo packages that refer to this (mt.yaml type package only)');
    argParser.addFlag('commit',
        abbr: 'c',
        defaultsTo: false,
        help: 'Perform git commit, using message');
  }

  Future<String> _bumpVersion(String version, String type) async {
    try {
      var newVersion = Version.parse(version);
      switch (type) {
        case 'major':
          newVersion = newVersion.incrementMajor();
          break;
        case 'minor':
          newVersion = newVersion.incrementMinor();
          break;
        case 'patch':
          newVersion = newVersion.incrementPatch();
          break;
        case 'prerelease':
          newVersion = newVersion.incrementPreRelease();
          break;
      }
      return newVersion.toString();
    } catch (e, _) {
      console.error("*** Fail! $e");
      console.log('');
//      print("*** Can't bump version ($version)! (Maybe the version string is not in semver format)");
      exit(1);
    }
  }

  /*
  recurse(String path) {
    // print('recurse(${path})');
    _updatePubspec(path);

    final dir = Directory(path);
    final dirList = dir.listSync();
    for (FileSystemEntity f in dirList) {
      if (f is File) {
        // print('File(${f.path})');
      } else {
        recurse(f.path);
      }
    }
  }
*/

  @override
  Future<void> run() async {
    bool verbose = false;
    if (globalResults?["verbose"]) {
      verbose = true;
    }

    bool dryRun = false;
    if (globalResults?['dry-run']) {
      dryRun = true;
      console.warn(" *** Note:  Dry Run - no files will be changed");
      console.warn("");
    }

    bool fix = false;
    if (argResults?["fix"]) {
      fix = true;
    }

    if (verbose) {
      mt_yaml.dump();
    }

    final type = argResults?['type'] ?? 'patch';
    var message = argResults?['message'] ?? [];
    if (message.length < 1) {
      message = await Editor().edit();
    }

    if (message.length < 1) {
      print('*** Aborted - no changelog/commit message');
      exit(1);
    }

    // bump version in pubspec.yaml
    final pubspec = Pubspec('.');
    final oldVersion = pubspec.version;
    final newVersion = await _bumpVersion(oldVersion, type);
    pubspec.version = newVersion;

    // bump version in changelog (add message and version heading)
    Changelog changelog = Changelog('.', dryRun, verbose);
    changelog.addVersion(newVersion, message);

    if (verbose) {
      pubspec.dump();
      print('');
      changelog.dump();
    }
    if (!dryRun) {
      pubspec.write();
      changelog.write();
    }

    if (fix) {
      final packages = Packages(dryRun, verbose);
      packages.updateReferences(pubspec.name, newVersion);
      if (!dryRun) {
        packages.write();
      }
    }

    console.log('');
    if (dryRun) {
      console.success(
          ' Updated ${pubspec.name}:  $type version from $oldVersion to $newVersion (DRY RUN)');
    } else {
      console.success(
          ' Updated ${pubspec.name}:  $type version from $oldVersion to $newVersion');
    }
    console.log('');
    // recurse(rest[0]);
  }
}
