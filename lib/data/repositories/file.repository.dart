import 'package:media_vault/data/services/sqlite.service.dart';
import 'package:media_vault/domain/models/file-system-node.model.dart';
import 'package:media_vault/util/result.dart';

class FileRepository {
  Future<Result<FileNode?>> getFile(String path) async {
    final db = await SqliteService.instance.database;

    return await db
        .query('File', where: 'path = ?', whereArgs: [path]).then((value) {
      if (value.isEmpty) {
        return Result.ok(null);
      }

      return Result.ok(
        FileNode(
          id: value.first['id'] as int,
          name: value.first['name'] as String,
          path: value.first['path'] as String,
          workspaceId: value.first['workspace_id'] as int,
          points: value.first['points'] as int?,
          completionDate: value.first['completion_date'] as String?,
        ),
      );
    });
  }

  Future<Result<FileNode>> upsertFile(FileNode file) async {
    final db = await SqliteService.instance.database;

    const String sql = '''
      INSERT INTO File (name, path, workspace_id, points, completion_date)
      VALUES (?, ?, ?, ?, ?)
      ON CONFLICT(path) DO UPDATE SET
        name = excluded.name,
        workspace_id = excluded.workspace_id,
        points = excluded.points,
        completion_date = excluded.completion_date;
    ''';

    await db.execute(sql, [
      file.name,
      file.path,
      file.workspaceId,
      file.points,
      file.completionDate,
    ]);

    final result = await getFile(file.path);

    switch (result) {
      case Ok<FileNode?>():
        if (result.value != null) {
          return Result.ok(result.value!);
        } else {
          throw Exception("Erro ao salvar File.");
        }
      case Error():
        throw result.error;
    }
  }
}
