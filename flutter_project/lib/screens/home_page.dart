import 'package:flutter/material.dart';
import '../models/list_item.dart';
import '../widgets/heading_item_widget.dart';
import '../widgets/message_item_widget.dart';
import '../widgets/image_item_widget.dart';
import '../widgets/date_item_widget.dart';
import '../utils/data_provider.dart';
import '../widgets/add_item_dialog.dart';
import '../widgets/edit_item_dialog.dart';
import 'api_data_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  List<ListItem> items = [];
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _loadItems();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  Future<void> _loadItems() async {
    final loadedItems = await DataProvider.getInitialItems();
    setState(() {
      items = loadedItems;
    });
    _controller.forward();
  }

  Future<void> _addItem() async {
    final result = await showDialog<ListItem>(
      context: context,
      builder: (BuildContext context) => AddItemDialog(),
    );

    if (result != null) {
      await DataProvider.addItem(result);
      setState(() {
        items.add(result);
      });
      _controller.reverse().then((_) => _controller.forward());
    }
  }

  Future<void> _editItem(ListItem item) async {
    final result = await showDialog<ListItem>(
      context: context,
      builder: (BuildContext context) => EditItemDialog(item: item),
    );

    if (result != null) {
      await DataProvider.updateItem(result);
      setState(() {
        final index = items.indexWhere((element) => element.id == result.id);
        if (index != -1) {
          items[index] = result;
        }
      });
    }
  }

  Future<void> _deleteItem(ListItem item) async {
    if (item.id != null) {
      await DataProvider.deleteItem(item.id!);
      setState(() {
        items.removeWhere((element) => element.id == item.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              Widget itemWidget;

              if (item is HeadingItem) {
                itemWidget = HeadingItemWidget(item: item);
              } else if (item is MessageItem) {
                itemWidget = MessageItemWidget(item: item);
              } else if (item is ImageItem) {
                itemWidget = ImageItemWidget(item: item);
              } else if (item is DateItem) {
                itemWidget = DateItemWidget(item: item);
              } else {
                itemWidget = const ListTile(title: Text('Unknown item type'));
              }

              return FadeTransition(
                opacity: _animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                  ).animate(_animation),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Dismissible(
                      key: Key('item_${item.id}'),
                      background: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        _deleteItem(item);
                      },
                      child: GestureDetector(
                        onTap: () => _editItem(item),
                        child: itemWidget,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: _addItem,
            tooltip: 'Add Item',
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
            elevation: 4,
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ApiDataPage()),
              );
            },
            tooltip: 'Fetch API Data',
            icon: const Icon(Icons.cloud_download),
            label: const Text('Fetch API Data'),
            elevation: 4,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}