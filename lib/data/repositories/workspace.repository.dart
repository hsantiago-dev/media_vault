import 'package:media_vault/domain/models/file-system-node.model.dart';
import 'package:media_vault/util/result.dart';

class WorkspaceRepository {
  DirectoryNode? _directoryNode;

  DirectoryNode? get directoryNode => _directoryNode;

  Future<Result<void>> saveWorkspace(DirectoryNode directoryNode) {
    _directoryNode = directoryNode;
    return Future.value(Result.ok(null));
  }
}
