import 'package:path/path.dart' as p;
import 'package:mt/console.dart';
import 'package:mt/pubspec_yaml.dart';
import 'package:mt/changelog.dart';

class Package {
  late final _pubspec;
  late final _changelog;
  late final _packageDir;
  late final _name;
  late final _dryRun;
  late final _verbose;

  bool _modified = false;

  Package(String packageDir, dryRun, verbose) {
    _packageDir = packageDir;
    _dryRun = dryRun;
    _verbose = verbose;
    _name = p.basename(packageDir);
    _pubspec = Pubspec(packageDir);

    _changelog = Changelog(packageDir, _dryRun, _verbose);
    // dump();
  }

  Changelog get changelog {
    return _changelog;
  }

  void updateReference(String package, String version) {
    print('updateReference package($_name) dependency($package) => $version ');
    _modified = true;
  }

  void dump() {
    console.dump('');
    console.dump('================================================================');
    console.dump('==== Package $_name ($_packageDir)');
    console.dump('================================================================');
    console.dump('  ${_pubspec.name} ${_pubspec.version}');
    console.dump('  ${_pubspec.description}');
    // _pubspec.dump();
    // _changelog.dump();
  }

  void write() {
    if (_modified) {
      print('write package $_name');
    }
  }
}

