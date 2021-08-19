///
/// MTConfig class
///
/// This class encapsulates the examination and manipulation of the ~/.mtconfig.yaml file.
///
/// While it's ugly to pollute a user's home diretory, we're sticking with the convention used by
/// git, which writes its global state to ~/.gitconfig.  This is obtained using this command:
/// ```
/// # git config --list --show-origin
/// ```
///
import 'dart:io' as io;
import 'package:mt/application.dart';
import 'package:yaml/yaml.dart';
import 'package:mt/console.dart';

class MTConfig {
  var _options;
  late final _path;
  bool _dirty = false;
  final mtconfig = '.mtconfig.yaml';

  MTConfig([global = false]) {
    if (global) {
      final homedir = io.Platform.environment['HOME']; // *nix only!
      _path = '$homedir/$mtconfig';
    } else {
      _path = '$mtconfig';
    }
    read();
  }

  void setOption(k, v) {
    _options[k] = v;
    _dirty = true;
  }

  String? getOption(k) {
    return _options[k];
  }

  ///
  /// Read our key/value pairs from ~/${mtconfig} as yaml.
  ///
  void read() {
    final f = io.File(_path);
    if (!f.existsSync()) {
      if (app.verbose) {
        print('~/${mtconfig} does not exist, using defaults.');
      }
      _options = {};
    } else {
      if (app.verbose) {
        print('Loaded existing ~/${mtconfig}.');
      }
      _options = Map.from(loadYaml(f.readAsStringSync()));
    }
  }

  ///
  /// Write our key/value pairs to ~/${mtconfig}.
  ///
  /// Currently all values are strings, so we can cheat by just writing key: value lines.
  ///
  void write() {
    if (_dirty) {
      final lines = [];
      _options.forEach((k, v) => lines.add('$k: $v'));

      if (app.dryRun) {
        console.log('DRY RUN - would write to $_path');
        console.dump(lines.join('\n'));
      }

      final f = io.File(_path);
      f.writeAsStringSync(lines.join('\n'));
      if (app.verbose) {
        console.dump(lines.join('\n'));
      }
    } else {
      
    }
  }
}
