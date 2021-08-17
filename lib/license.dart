import 'dart:io';
import 'package:mt/editable_file.dart';
import 'package:mt/mt_yaml.dart';

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
  late final _filename;
  bool _dryRun = false, _verbose = false;

  // index is SPDX short identifier
  // see https://opensource.org/licenses
  final licenseTypes = {
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

  License(String path, String type, bool dryRun, bool verbose)
      : super('$path/LICENSE', []) {
    _path = path;
    _dryRun = dryRun;
    _verbose = verbose;

    if (_verbose) {
      if (dirty) {
        print('loaded existing LICENSE $_path/LICENSE');
      } else {
        setLicense(type);
      }
    }
  }

  @override
  void write([String? filename, makeBackup = true]) {
    if (!_dryRun) {
      print("LICENCE write($_filename)");
      super.write(filename, makeBackup);
    } else {
      if (_verbose) {
        print("dry run: not writing $filename");
      }
    }
  }

  bool setLicense(String type, [bool override = true]) {
    if (licenseTypes.containsKey(type)) {
      final filename = licenseTypes[type];
      print("$filename");
      dirty = true;
      return read('./lib/licenses/$filename');
    }
    print('no license file for $type');
    return false;
  }
}
