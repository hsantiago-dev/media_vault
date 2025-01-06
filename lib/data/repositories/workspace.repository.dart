import 'dart:io';

import 'package:media_vault/data/services/sqlite.service.dart';
import 'package:media_vault/domain/models/file-system-node.model.dart';
import 'package:media_vault/domain/models/workspace.model.dart';
import 'package:media_vault/util/result.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class WorkspaceRepository {
  Future<Result<Workspace>> getWorkspace(int id) async {
    final db = await SqliteService.instance.database;

    return await db
        .query('Workspace', where: 'id = ?', whereArgs: [id]).then((value) {
      if (value.isEmpty) {
        return Result.error(Exception("Workspace não encontrado."));
      }

      final workspaceNode =
          getWorkspaceSystemNode(value.first['path'] as String);

      return Result.ok(
        Workspace(
          id: value.first['id'] as int,
          name: value.first['name'] as String,
          path: value.first['path'] as String,
          workspaceNode: workspaceNode,
        ),
      );
    });
  }

  Future<Result<List<Workspace>>> getWorkspaces() async {
    final db = await SqliteService.instance.database;

    return await db.query('Workspace').then((value) {
      final workspaces = value
          .map((e) => Workspace(
                id: e['id'] as int,
                name: e['name'] as String,
                path: e['path'] as String,
              ))
          .toList();
      return Result.ok(workspaces);
    });
  }

  Future<Result<Workspace>> saveWorkspace(Workspace workspace) async {
    final workspaceNode = getWorkspaceSystemNode(workspace.path);

    if (workspaceNode == null) {
      return Future.value(
          Result<Workspace>.error(Exception("Diretório inválido.")));
    }

    final db = await SqliteService.instance.database;

    final id = await db.insert(
      'Workspace',
      {'name': workspace.name, 'path': workspace.path},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (id == 0) {
      return Future.value(
          Result<Workspace>.error(Exception("Erro ao salvar workspace.")));
    }

    return Future.value(
      Result.ok(
        Workspace(
          id: id,
          name: workspace.name,
          path: workspace.path,
          workspaceNode: workspaceNode,
        ),
      ),
    );
  }

  DirectoryNode? getWorkspaceSystemNode(String path) {
    final directory = Directory(path);
    if (!directory.existsSync()) {
      return null;
    }

    final directoryNode = _convertDirectoryToNode(directory);
    _updatePercentageConcluded(directoryNode);

    return directoryNode;
  }

  DirectoryNode _convertDirectoryToNode(Directory directory) {
    final DirectoryNode node =
        DirectoryNode(directory.path.split(Platform.pathSeparator).last);

    final List<FileSystemEntity> entities = directory.listSync();
    bool isWatched = false;
    for (final entity in entities) {
      if (entity is Directory) {
        node.addChild(_convertDirectoryToNode(entity));
      } else if (entity is File) {
        node.addChild(FileNode(entity.path.split(Platform.pathSeparator).last,
            entity.path, isWatched));
        isWatched = !isWatched;
      }
    }

    return node;
  }

  void _updatePercentageConcluded(DirectoryNode directoryNode) {
    int calculateAndSet(DirectoryNode dir) {
      int totalFiles = 0;
      int checkedFiles = 0;

      for (var child in dir.children) {
        if (child is FileNode) {
          totalFiles++;
          if (child.isChecked) {
            checkedFiles++;
          }
        } else if (child is DirectoryNode) {
          int subFiles = calculateAndSet(child);
          totalFiles += subFiles;
          checkedFiles += (subFiles * child.percentageConcluded).toInt();
        }
      }

      dir.percentageConcluded =
          totalFiles == 0 ? 0.0 : (checkedFiles / totalFiles);
      return totalFiles;
    }

    calculateAndSet(directoryNode);
  }
}
