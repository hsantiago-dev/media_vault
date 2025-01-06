import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SqliteService {
  final String _databaseName = 'media_vault.db';
  final int _databaseVersion = 1;

  // Singleton
  static final SqliteService instance = SqliteService._privateConstructor();
  SqliteService._privateConstructor();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    return await databaseFactoryFfi.openDatabase(
      _databaseName,
      options: OpenDatabaseOptions(
        version: _databaseVersion,
        onCreate: _onCreate,
      ),
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Workspace (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT NOT NULL,
        path TEXT NOT NULL,
        CONSTRAINT idx_workspace_path UNIQUE (path)
      );

      CREATE TABLE File (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT NOT NULL,
        path TEXT NOT NULL,
        workspace_id INTEGER NOT NULL,
        points INTEGER DEFAULT 0,
        completion_date TEXT,
        FOREIGN KEY (workspace_id) REFERENCES Workspace(id) ON DELETE CASCADE,
        CONSTRAINT idx_file_path UNIQUE (path)
      );
    ''');
  }
}
