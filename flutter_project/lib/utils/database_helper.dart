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
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT,
        last_name TEXT,
        email TEXT,
        avatar TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE beers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        style TEXT,
        alcohol TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE banks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bank_name TEXT,
        account_number TEXT,
        iban TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE addresses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        street_name TEXT,
        street_address TEXT,
        city TEXT,
        state TEXT,
        zip_code TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE appliances(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        equipment TEXT,
        brand TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add the 'date' column if it doesn't exist
      await db.execute('ALTER TABLE items ADD COLUMN date TEXT');
      await db.execute('''
      CREATE TABLE IF NOT EXISTS users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT,
        last_name TEXT,
        email TEXT,
        avatar TEXT
      )
    ''');

      await db.execute('''
      CREATE TABLE IF NOT EXISTS beers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        style TEXT,
        alcohol TEXT
      )
    ''');

      await db.execute('''
      CREATE TABLE IF NOT EXISTS banks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bank_name TEXT,
        account_number TEXT,
        iban TEXT
      )
    ''');

      await db.execute('''
      CREATE TABLE IF NOT EXISTS addresses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        street_name TEXT,
        street_address TEXT,
        city TEXT,
        state TEXT,
        zip_code TEXT
      )
    ''');

      await db.execute('''
      CREATE TABLE IF NOT EXISTS appliances(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        equipment TEXT,
        brand TEXT
      )
    ''');
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

  Future<void> insertData(String table, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<void> insertApiData(String dataType, List<dynamic> apiData) async {
    for (var item in apiData) {
      switch (dataType) {
        case 'users':
          await insertData('users', {
            'first_name': item['first_name'],
            'last_name': item['last_name'],
            'email': item['email'],
            'avatar': item['avatar']
          });
          break;
        case 'beers':
          await insertData('beers', {
            'name': item['name'],
            'style': item['style'],
            'alcohol': item['alcohol']
          });
          break;
        case 'banks':
          await insertData('banks', {
            'bank_name': item['bank_name'],
            'account_number': item['account_number'],
            'iban': item['iban']
          });
          break;
        case 'addresses':
          await insertData('addresses', {
            'street_name': item['street_name'],
            'street_address': item['street_address'],
            'city': item['city'],
            'state': item['state'],
            'zip_code': item['zip_code']
          });
          break;
        case 'appliances':
          await insertData('appliances', {
            'equipment': item['equipment'],
            'brand': item['brand']
          });
          break;
        default:
          throw Exception('Unknown data type: $dataType');
      }
    }
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

  Future<void> deleteDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'listItems.db');

    await deleteDatabase(path);
  }
}