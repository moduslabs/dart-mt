import 'package:mt/editable_file.dart';

class License extends EditableFile {
  late final _path;
  late final _filename;
  bool _dryRun = false, _verbose = false;
  License(String path, bool dryRun, bool verbose)
      : super('$path/LICENSE', [
          'MIT License',
          '',
          'Copyright (c) 2021 Modus Labs',
          '',
          'Permission is hereby granted, free of charge, to any person obtaining a copy',
          'of this software and associated documentation files (the "Software"), to deal',
          'in the Software without restriction, including without limitation the rights',
          'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell',
          'copies of the Software, and to permit persons to whom the Software is',
          'furnished to do so, subject to the following conditions:',
          '',
          'The above copyright notice and this permission notice shall be included in all',
          'copies or substantial portions of the Software.',
          '',
          'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR',
          'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,',
          'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE',
          'AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER',
          'LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,',
          'OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS',
        ]) {
    _path = path;
    _dryRun = dryRun;
    _verbose = verbose;

    if (_verbose) {
      print('loaded CHANGELOG $_path');
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
}
