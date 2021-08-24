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

class ConfigFile {
  final mtconfig = MTConfig.mtconfig;

  var _options;
  late final _path;
  bool _dirty = false;

  ConfigFile(path) {
    _path = path;
    read();
  }

  void setOption(String k, String v) {
    _options[k] = v;
    _dirty = true;
  }

  String? getOption(String k) {
    return _options[k];
  }

  void removeOption(String k) {
    if (_options.remove(k) != null) {
      _dirty = true;
    }
  }

  void dump() {
    _options.forEach((k,v) => print('${_path.padRight(32)} $k = $v'));
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
      final input = f.readAsStringSync();
      _options = input.length > 0 ? Map.from(loadYaml(input)) : {};
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
    } else {}
  }
}

class MTConfig {
  static final mtconfig = '.mtconfig.yaml';
  late final ConfigFile etc;
  late final ConfigFile home;
  late final ConfigFile local;

  MTConfig() {
    final homedir = io.Platform.environment['HOME']; // *nix only!

    etc = ConfigFile('/etc/mtconfig.yaml');
    home = ConfigFile('$homedir/$mtconfig');
    local = ConfigFile('$mtconfig');
  }

  void setOption(String key, String value, [global = true]) {
    if (global) {
      home.setOption(key, value);
    } else {
      local.setOption(key, value);
    }
  }

  String? getOption(String k) {
    String? o = local.getOption(k);
    if (o == null) {
      o = home.getOption(k);
    }
    if (o == null) {
      o = etc.getOption(k);
    }
    return o;
  }

  void removeOption(String k, bool global) {
    if (global) {
      home.removeOption(k);
    } else {
      local.removeOption(k);
    }
  }

  void write() {
    local.write();
    home.write();
  }

  void dump() {
    etc.dump();
    local.dump();
    home.dump();
  }
}
