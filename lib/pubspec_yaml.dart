import 'package:mt/yaml_file.dart';

class Pubspec extends YamlFile {
  late final _name;

  Pubspec(String path) : super('$path', 'pubspec.yaml') {}

  List<String> get keys {
    return [
      'name',
      'version',
      'description',
      'homepage',
      'repository',
      'issue_tracker',
      'documentation',
      'dependencies',
      'dev_dependencies',
      'dependency_overrides',
      'environment',
      'executables',
      'publish_to'
    ];
  }

  void set version(String ver) {
    doc['version'] = ver;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].startsWith('version:')) {
        lines[i] = 'version: $ver';
        return;
      }
    }
    if (lines.length == 0) {
      lines.insert(0, 'version: $ver');
    } else {
      lines.insert(1, 'version: $ver');
    }
  }

  String get version {
    return doc['version'];
  }

  String get name {
    return _name;
  }

  String get description {
    return doc['description'];
  }

  bool setDependency(String package, dynamic value) {
    final dependencies = getValue('dependencies') ?? {};
    dependencies[package] = value;
    setValue('dependencies', dependencies);
    return true;
  }

  bool hasDependency(String package) {
    final dependencies = getValue('dependencies');
    return (dependencies.indexOf(package) > -1);
  }

  dynamic getDependency(String package) {
    final dependencies = getValue('dependencies');
    final index = dependencies.indexOf(package);
    if (index > -1) {
      return dependencies[index];
    }
    return null;
  }

  @override
  String toString() {
    return 'pubspec $path/pubspec.yaml\n$lines';
  }
}
