import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  late Database _database;

  Future<void> initDatabase() async {
    _database = await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'my_database.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade:_onUpgrade,
    );

  }
  Future<void> _onUpgrade(Database db,int oldVersion ,int newVersion) async {
    await db.execute('''
      CREATE TABLE todo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        city_id INTEGER REFERENCES city on city_id
      )
    ''');
    await db.execute('''
      CREATE TABLE city (
        city_id INTEGER PRIMARY KEY AUTOINCREMENT,
        city_name TEXT
      )
    ''');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        city TEXT
      )
    ''');
  }

  Future<int> insertTodo(Map<String, dynamic> todo) async {
    return await _database.insert(
      'todo',
      todo,
    );
  }

  Future<List<Map<String, dynamic>>> getAllTodos() async {
    return await _database.query('todo');
  }

  Future<Map<String, dynamic>?> getTodoById(int id) async {
    final List<Map<String, dynamic>> result =
        await _database.query('todo', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<int> updateTodo(int id, Map<String, dynamic> newValues) async {
    return await _database.update(
      'todo',
      newValues,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTodo(int id) async {
    return await _database.delete(
      'todo',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
