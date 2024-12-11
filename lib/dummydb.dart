import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _db;

  DatabaseHelper._instance();

  String tableName = "tasks";
  String colId = "id";
  String colTitle = "title";
  String colDate = "date";
  String colTime = "time";
  String colStatus = "status";

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'todo.db');

    return await openDatabase(
      path,
      version: 2, 
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            $colId INTEGER PRIMARY KEY AUTOINCREMENT,
            $colTitle TEXT NOT NULL,
            $colDate TEXT NOT NULL,
            $colTime TEXT NOT NULL,
            $colStatus INTEGER NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE $tableName ADD COLUMN $colTime TEXT');
        }
      },
    );
  }

  Future<int> insertTask(Map<String, dynamic> task) async {
    final db = await database;
    return await db.insert(tableName, task);
  }

  Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await database;
    return await db.query(tableName, orderBy: '$colDate ASC');
  }

  Future<int> updateTask(int id, Map<String, dynamic> updatedTask) async {
    final db = await database;
    return await db.update(
      tableName,
      updatedTask,
      where: '$colId = ?',
      whereArgs: [id],
    );
  }
 
  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(tableName, where: '$colId = ?', whereArgs: [id]);
  }
}


