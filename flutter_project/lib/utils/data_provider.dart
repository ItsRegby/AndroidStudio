import '../models/list_item.dart';
import 'database_helper.dart';

class DataProvider {
  static Future<List<ListItem>> getInitialItems() async {
    final dbHelper = DatabaseHelper.instance;
    final items = await dbHelper.getItems();
    if (items.isEmpty) {
      // If the database is empty, add some initial items
      final initialItems = [
        HeadingItem('Heading 1'),
        MessageItem('Sender 1', 'Message body 1'),
        ImageItem('https://example.com/image.jpg', 'Image 1'),
        DateItem(DateTime.now(), 'Today\'s date'),
      ];
      for (var item in initialItems) {
        await dbHelper.insertItem(item);
      }
      return initialItems;
    }
    return items;
  }

  static Future<void> addItem(ListItem item) async {
    await DatabaseHelper.instance.insertItem(item);
  }

  static Future<void> deleteItem(int id) async {
    await DatabaseHelper.instance.deleteItem(id);
  }

  static Future<void> updateItem(ListItem item) async {
    await DatabaseHelper.instance.updateItem(item);
  }
}