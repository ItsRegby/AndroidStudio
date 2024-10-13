import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/list_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('listItems.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        heading TEXT,
        sender TEXT,
        body TEXT,
        imageUrl TEXT,
        description TEXT,
        date TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add the 'date' column if it doesn't exist
      await db.execute('ALTER TABLE items ADD COLUMN date TEXT');
    }
  }

  Future<int> insertItem(ListItem item) async {
    final db = await database;
    final Map<String, dynamic> data;
    if (item is HeadingItem) {
      data = {'type': 'heading', 'heading': item.heading};
    } else if (item is MessageItem) {
      data = {'type': 'message', 'sender': item.sender, 'body': item.body};
    } else if (item is ImageItem) {
      data = {'type': 'image', 'imageUrl': item.imageUrl, 'description': item.description};
    } else if (item is DateItem) {
      data = {'type': 'date', 'date': item.date.toIso8601String(), 'description': item.description};
    } else {
      throw Exception('Unknown item type');
    }
    return await db.insert('items', data);
  }

  Future<List<ListItem>> getItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('items');
    return List.generate(maps.length, (i) {
      final type = maps[i]['type'];
      final id = maps[i]['id'] as int;
      switch (type) {
        case 'heading':
          return HeadingItem(maps[i]['heading'], id: id);
        case 'message':
          return MessageItem(maps[i]['sender'], maps[i]['body'], id: id);
        case 'image':
          return ImageItem(maps[i]['imageUrl'], maps[i]['description'], id: id);
        case 'date':
          return DateItem(DateTime.parse(maps[i]['date']), maps[i]['description'], id: id);
        default:
          throw Exception('Unknown item type: $type');
      }
    });
  }

  Future<int> updateItem(ListItem item) async {
    final db = await database;
    final Map<String, dynamic> data;
    if (item is HeadingItem) {
      data = {'type': 'heading', 'heading': item.heading};
    } else if (item is MessageItem) {
      data = {'type': 'message', 'sender': item.sender, 'body': item.body};
    } else if (item is ImageItem) {
      data = {'type': 'image', 'imageUrl': item.imageUrl, 'description': item.description};
    } else if (item is DateItem) {
      data = {'type': 'date', 'date': item.date.toIso8601String(), 'description': item.description};
    } else {
      throw Exception('Unknown item type');
    }
    return await db.update('items', data, where: 'id = ?', whereArgs: [item.id]);
  }

  Future<void> deleteItem(int id) async {
    final db = await database;
    await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllItems() async {
    final db = await database;
    await db.delete('items');
  }
}