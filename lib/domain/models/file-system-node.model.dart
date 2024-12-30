// Classe base para representar um nó no sistema de arquivos.
abstract class FileSystemNode {
  final String name;
  final String type;

  FileSystemNode(this.name, this.type);
}

// Classe para representar um arquivo.
class FileNode extends FileSystemNode {
  final String path;
  final bool isChecked;

  FileNode(String name, this.path, this.isChecked) : super(name, "file");

  @override
  String toString() => 'FileNode(name: $name, path: $path)';
}

// Classe para representar um diretório.
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
