import 'dart:io';

import 'package:media_vault/data/repositories/file.repository.dart';
import 'package:media_vault/data/services/sqlite.service.dart';
import 'package:media_vault/domain/models/file-system-node.model.dart';
import 'package:media_vault/domain/models/workspace.model.dart';
import 'package:media_vault/util/result.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class WorkspaceRepository {
  late final FileRepository _fileRepository;
  WorkspaceRepository(FileRepository fileRepository) {
    _fileRepository = fileRepository;
  }

  Future<Result<Workspace>> getWorkspace(int id) async {
    final db = await SqliteService.instance.database;

    return await db.query('Workspace', where: 'id = ?', whereArgs: [id]).then(
        (value) async {
      if (value.isEmpty) {
        return Result.error(Exception("Workspace não encontrado."));
      }

      final workspaceNode = await getWorkspaceSystemNode(
        path: value.first['path'] as String,
        workspaceId: value.first['id'] as int,
      );

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
    final directory = Directory(workspace.path);
    if (!directory.existsSync()) {
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

    final workspaceNode =
        await getWorkspaceSystemNode(path: workspace.path, workspaceId: id);

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

  Future<DirectoryNode?> getWorkspaceSystemNode(
      {required String path, required int workspaceId}) async {
    final directory = Directory(path);
    if (!directory.existsSync()) {
      return null;
    }

    final directoryNode = await _syncronizeFileSystemNode(
        directory: directory, workspaceId: workspaceId);
    _updatePercentageConcluded(directoryNode);

    return directoryNode;
  }

  Future<DirectoryNode> _syncronizeFileSystemNode(
      {required Directory directory, required int workspaceId}) async {
    final DirectoryNode node =
        DirectoryNode(directory.path.split(Platform.pathSeparator).last);

    final List<FileSystemEntity> entities = directory.listSync();
    for (final entity in entities) {
      if (entity is Directory) {
        node.addChild(await _syncronizeFileSystemNode(
            directory: entity, workspaceId: workspaceId));
      } else if (entity is File) {
        Result<FileNode?> result = await _fileRepository.getFile(entity.path);
        FileNode? file;

        switch (result) {
          case Ok<FileNode?>():
            if (result.value != null) {
              file = result.value;
            }
            break;
          case Error():
            throw result.error;
        }

        node.addChild(
          file ??
              FileNode.newFile(
                name: entity.path.split(Platform.pathSeparator).last,
                path: entity.path,
                workspaceId: workspaceId,
              ),
        );
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
          if (child.completionDate != null) {
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
