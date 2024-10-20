import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class ApiDataPage extends StatefulWidget {
  const ApiDataPage({Key? key}) : super(key: key);

  @override
  _ApiDataPageState createState() => _ApiDataPageState();
}

class _ApiDataPageState extends State<ApiDataPage> {
  List<dynamic> data = [];
  bool isLoading = false;
  String currentDataType = 'users';
  final int itemsPerPage = 10;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  String errorMessage = '';

  final Map<String, String> dataTypes = {
    'users': 'Users',
    'beers': 'Beers',
    'banks': 'Banks',
    'addresses': 'Addresses',
    'appliances': 'Appliances',
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    loadDataFromDatabase(); // Load data from database first
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      fetchData();
    }
  }

  Future<void> fetchData() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://random-data-api.com/api/v2/$currentDataType?size=$itemsPerPage&page=$_currentPage'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> newData = json.decode(response.body);

        await DatabaseHelper.instance.insertApiData(currentDataType, newData);

        setState(() {
          data.addAll(newData);
          _currentPage++;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        errorMessage = 'Failed to load data. Please try again.';
        isLoading = false;
      });
    }
  }


  // Load data from the database based on the currentDataType
  Future<void> loadDataFromDatabase() async {
    try {
      final List<Map<String, dynamic>> dbData = await DatabaseHelper.instance.getData(currentDataType);
      setState(() {
        data = List.from(dbData);
        _currentPage = (dbData.length ~/ itemsPerPage) + 1;
      });
    } catch (e) {
      print('Error loading data from database: $e');
      setState(() {
        errorMessage = 'Failed to load data from the database.';
      });
    }
  }


  Future<void> refreshData() async {
    setState(() {
      _currentPage = 1;
      data.clear();
    });
    await loadDataFromDatabase();
    await fetchData();
  }

  Widget buildDataCard(dynamic item) {
    switch (currentDataType) {
      case 'users':
        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(item['avatar']),
            ),
            title: Text('${item['first_name']} ${item['last_name']}'),
            subtitle: Text(item['email']),
          ),
        );
      case 'beers':
        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(item['name']),
            subtitle: Text('${item['style']} - ${item['alcohol']}'),
          ),
        );
      case 'banks':
        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(item['bank_name']),
            subtitle: Text('${item['account_number']}\n${item['iban']}'),
          ),
        );
      case 'addresses':
        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text('${item['street_name']} ${item['street_address']}'),
            subtitle: Text('${item['city']}, ${item['state']} ${item['zip_code']}'),
          ),
        );
      case 'appliances':
        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(item['equipment']),
            subtitle: Text('Brand: ${item['brand']}'),
          ),
        );
      default:
        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(item.toString()),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Random ${dataTypes[currentDataType]}'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                currentDataType = value;
                _currentPage = 1;
              });
              refreshData();
            },
            itemBuilder: (BuildContext context) => dataTypes.entries.map((entry) =>
                PopupMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                )
            ).toList(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: errorMessage.isNotEmpty
            ? Center(child: Text(errorMessage))
            : ListView.builder(
          controller: _scrollController,
          itemCount: data.length + 1,
          itemBuilder: (context, index) {
            if (index < data.length) {
              return buildDataCard(data[index]);
            } else if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}
