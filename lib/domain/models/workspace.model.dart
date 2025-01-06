import 'package:media_vault/domain/models/file-system-node.model.dart';

class Workspace {
  final int id;
  final String name;
  final String path;
  final DirectoryNode? workspaceNode;

  Workspace({
    required this.id,
    required this.name,
    required this.path,
    this.workspaceNode,
  });

  factory Workspace.newWorkspace({required String name, required String path}) {
    return Workspace(
      id: 0,
      name: name,
      path: path,
    );
  }
}
