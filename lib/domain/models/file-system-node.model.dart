abstract class FileSystemNode {
  final String name;
  final String type;

  FileSystemNode(this.name, this.type);
}

class FileNode extends FileSystemNode {
  final int? id;
  @override
  final String name;
  final String path;
  final int workspaceId;
  final int? points;
  final String? completionDate;

  FileNode({
    this.id,
    required this.name,
    required this.path,
    required this.workspaceId,
    this.points,
    this.completionDate,
  }) : super(name, "file");

  factory FileNode.newFile(
      {required String name, required String path, required int workspaceId}) {
    return FileNode(
      name: name,
      path: path,
      workspaceId: workspaceId,
    );
  }

  @override
  String toString() => 'FileNode(name: $name, path: $path)';
}

class DirectoryNode extends FileSystemNode {
  double percentageConcluded = 0.0;
  final List<FileSystemNode> children;

  DirectoryNode(String name)
      : children = [],
        super(name, "directory");

  void addChild(FileSystemNode child) {
    children.add(child);
  }

  @override
  String toString() => 'DirectoryNode(name: $name, children: $children)';
}
