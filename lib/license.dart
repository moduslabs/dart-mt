/*import 'dart:io';*/
import 'dart:convert' show utf8;
/*import 'package:path/path.dart' as p;*/
import 'package:mt/editable_file.dart';
import 'package:mt/application.dart';
import 'package:mt/mt_yaml.dart';
import 'package:resource_portable/resource.dart';

//
// licenses are located in lib/licenses/
//
// Some licenses require source files to contain a copyright notice in comments at the top.
// These are found in lib/licenses/<license>-headers.txt
//
// Some licenses require cli programs to print a copyright notice as a banner (first thing printed
// at program start).  These are found in lib/licenses/<license>-banner.txt.
//

class License extends EditableFile {
  late final _path;
/*  late final _filename;*/
  bool _dryRun = false, _verbose = false;

  // index is SPDX short identifier
  // see https://opensource.org/licenses
  static final licenseTypes = {
    "Apache-2.0": 'apache2.txt',
    "BSD-2-Clause": 'bsd2clause.txt',
    "BSD-3-Clause": 'bsd3clause.txt',
    "GPL-2.0": 'gpl2.txt',
    "GPL-3.0": 'gpl3.txt',
    "LGPL-2.0": 'gpl2.txt',
    "LGPL-2.1": 'gpl2.1.txt',
    "LGPL-3.0": 'gpl3.txt',
    "MIT": 'mit.txt',
    "Mozilla-2.0": 'mozilla.txt',
    "CDDL-1.0": 'cddl.txt',
    "EPL-2.0": 'eclipse2.txt',
  };

  License(String path, bool dryRun, bool verbose) : super('$path', []) {
    _path = path;
    _dryRun = dryRun;
    _verbose = verbose;

    if (_verbose) {
      if (dirty) {
        print('loaded existing LICENSE $_path/LICENSE');
      }
    }
  }

  @override
  void write([String? filename, makeBackup = true]) {
    if (filename == null) {
      filename = 'LICENSE';
    }
    
    if (!_dryRun) {
      super.write(filename, makeBackup);
      if (_verbose) {
        app.log('  Wrote $filename.');
      }
    } else {
      if (_verbose) {
        print("dry run: not writing $filename");
      }
    }
  }

  Future<bool> setLicense(String type,
      [ProjectOptions? mt_yaml, bool override = true]) async {
    if (mt_yaml == null) {
      mt_yaml = app.mt_yaml;
    }
    if (licenseTypes.containsKey(type)) {
      final filename = licenseTypes[type];

      dirty = true;
      final resource = new Resource('package:mt/assets/licenses/$filename');
      lines.clear();
      var s = await resource.readAsString(encoding: utf8);
      s = s.replaceAll('<YEAR>', mt_yaml.getValue('copyrightYear').toString());
      s = s.replaceAll('<COPYRIGHT HOLDER>', mt_yaml.getValue('publisher') ?? '');
      s = s.replaceAll('<NAME>', mt_yaml.getValue('name') ?? '');
      s = s.replaceAll('<AUTHOR>', mt_yaml.getValue('author') ?? '');
      s = s.replaceAll('<DESCRIPTION>', mt_yaml.getValue('description'));
      lines.addAll(s.split('\n'));
      return true;
    }
    print('no license file for $type');
    return false;
  }
}
