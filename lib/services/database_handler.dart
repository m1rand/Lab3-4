import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/sensor.dart';

class DatabaseHandler {
  static Database? _database;

  // Підключення до БД
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Ініціалізація БД
  static Future<Database> _initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'sensors.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Створення таблиці
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Sensor(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        value REAL
      )
    ''');
  }

  // Додавання сенсора
  Future<void> insertSensor(Sensor sensor) async {
    final db = await database;
    await db.insert('Sensor', sensor.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Отримання сенсорів
  Future<List<Sensor>> getSensors() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Sensor');
    return List.generate(maps.length, (i) {
      return Sensor.fromMap(maps[i]);
    });
  }
}
