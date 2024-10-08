import 'package:flutter/material.dart';
import '/screens/second_activity.dart';
import '../widgets/navigation_drawer.dart';

class MainActivity extends StatefulWidget {
  const MainActivity({super.key});

  @override
  _MainActivityState createState() => _MainActivityState();
}

class _MainActivityState extends State<MainActivity> {
  int _selectedIndex = 0;

  static final List<Widget> _fragments = <Widget>[
    const FragmentOne(),
    const FragmentTwo(),
    const FragmentThree(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Activity', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: _fragments[_selectedIndex],
      drawer: AppNavigationDrawer(
        onNavigateToSecondActivity: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SecondActivity()),
          );
        },
        onSelectFragment: _onItemTapped,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Main',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Text',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Favorite',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
      ),
    );
  }
}

class FragmentOne extends StatefulWidget {
  const FragmentOne({super.key});

  @override
  _FragmentOneState createState() => _FragmentOneState();
}

class _FragmentOneState extends State<FragmentOne> with AutomaticKeepAliveClientMixin {
  int _counter = 0;

  @override
  bool get wantKeepAlive => true;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight, minWidth: constraints.maxWidth),
            child: IntrinsicHeight(
              child: Container(
                color: Colors.teal.shade50,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome to Fragment 1',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.teal),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Counter: $_counter',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _incrementCounter,
                      icon: const Icon(Icons.add),
                      label: const Text('Increase'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class FragmentTwo extends StatefulWidget {
  const FragmentTwo({super.key});

  @override
  _FragmentTwoState createState() => _FragmentTwoState();
}

class _FragmentTwoState extends State<FragmentTwo> with AutomaticKeepAliveClientMixin {
  String _enteredText = '';
  final TextEditingController _controller = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight, minWidth: constraints.maxWidth),
            child: IntrinsicHeight(
              child: Container(
                color: Colors.orange.shade50,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'This is Fragment 2',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.orange),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: 'Enter something',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _enteredText = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'You entered: $_enteredText',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class FragmentThree extends StatefulWidget {
  const FragmentThree({super.key});

  @override
  _FragmentThreeState createState() => _FragmentThreeState();
}

class _FragmentThreeState extends State<FragmentThree> with AutomaticKeepAliveClientMixin {
  bool _isLiked = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight, minWidth: constraints.maxWidth),
            child: IntrinsicHeight(
              child: Container(
                color: Colors.purple.shade50,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Fragment 3 is here!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.purple),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    IconButton(
                      icon: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: Colors.purple,
                      ),
                      iconSize: 50,
                      onPressed: () {
                        setState(() {
                          _isLiked = !_isLiked;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_isLiked ? 'Added to favorites!' : 'Removed from favorites!'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isLiked ? 'You like it!' : 'Click to Like',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}