import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String _dbName = 'quiz.db';
  static const String _tableName = 'scores';
  static const int _dbVersion = 1;

  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, _dbName);

    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        score INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertScore(String username, int score) async {
    final db = await database;
    return await db.insert(_tableName, {'username': username, 'score': score});
  }

  Future<List<Map<String, dynamic>>> getScores() async {
    final db = await database;
    return await db.query(_tableName, orderBy: 'score DESC');
  }

  Future<int> limparBanco() async {
    final db = await database;
    return await db.delete(_tableName);
  }
}
