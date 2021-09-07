import 'package:mt/mtcommand.dart';
import 'package:mt/git.dart';

class RootCommand extends MTCommand {
  final name = 'root';
  final description = 'Print root directory of git repository';

  @override
  Future<String?> exec() async {
    String? result = await Git.root();
    if (result.length == 0) {
      abort('*** Not in a git repository');
    }
    print(result);
    return result;
  }
}
