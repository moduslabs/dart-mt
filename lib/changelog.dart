/*import 'dart:io';*/
import 'package:version/version.dart';
import 'package:mt/editable_file.dart';
/*import 'package:mt/console.dart';*/

///
/// private class used by Changelog to represent a version title and message (in markdown)
///
class ChangeEntry {
  var version;
  var lines;

  ChangeEntry(String version, List<String> lines) {
    this.version = version.length > 0 ? Version.parse(version) : '';
    this.lines = lines;
  }
  String toString() {
    return 'ChangeEntry $version';
  }
}

///
/// Changelog class
///
/// Represents a CHANGELOG.md file.
///
/// Once loaded, a CHANGELOG can be modified and written to a file.
///
class Changelog extends EditableFile {
  late final _path;
  late final _dryRun;
  late final _verbose;

  final _changes = [];

  static String nowFormatted() {
    var d = DateTime.now();
    return '${d.month}/${d.day}/${d.year}';
  }

  ///
  /// Constructor
  ///
  /// Open the CHANGELOG.md file and read it in as lines.  Or create the lines if the file doesn't exist.
  ///
  Changelog(String path, bool dryRun, bool verbose)
      : super('$path/CHANGELOG.md', [
          '## 0.0.0 - ${Changelog.nowFormatted}',
          'Initial version',
        ]) {
    _path = path;
    _dryRun = dryRun;
    _verbose = verbose;

    // Break up lines into "head" lines and array of ChangeEntry instances.
    // The head lines are just lines that appear in the .md file before any version declarations.
    int index = 0;

    //
    if (lines.length > 0) {
      if (!lines[0].startsWith('##')) {
        while (index < lines.length) {
          final line = lines[index];
          if (line.startsWith('## ')) {
            break;
          }
          head.add(line);
          index++;
        }
      }

      // parse the rest of the CHANGELOG into ChangeEntry instances, one per version.
      List<String> change = [];
      String version = '';
      while (index < lines.length) {
        final line = lines[index];
        if (line.startsWith('## ')) {
          if (change.length > 0) {
            _changes.add(ChangeEntry(version, change));
          }
          change = [line];
          final parts = line.split(new RegExp('\\s+'));
          version = parts[1];
        } else if (change.length > 0) {
          change.add(line);
        } else {
          change = [line];
          version = '';
        }
        index++;
      }

      // maybe add last change (that wasn't added in the above loop)
      if (change.length > 0) {
        change.add('');
        _changes.add(ChangeEntry(version, change));
      }

      // sort _changes by version, newest first
      _changes.sort((a, b) => b.version.compareTo(a.version));
      List<String> newLines = [];
      for (var c in _changes) {
        newLines += c.lines;
      }
      lines = newLines;

      if (_verbose) {
        print('loaded CHANGELOG $_path');
      }
    }
  }

  void addVersion(String version, String message) {
    var d = DateTime.now();
    if (message == '') {
      message = 'Bump version';
    }
    lines.insert(0, '');
    lines.insert(0, '$message');
    lines.insert(0, '## $version - ${d.month}/${d.day}/${d.year}');
  }

  @override
  void write([String? fn, makeBackup = true]) {
    if (!_dryRun) {
      super.write(fn, makeBackup);
      if (_verbose) {
        print("  Wrote changelog ${fn ?? this.path}.");
      }
    } else {
      if (_verbose) {
        print("  Dry run: not writing ${fn ?? this.path}.");
      }
    }
  }
}
