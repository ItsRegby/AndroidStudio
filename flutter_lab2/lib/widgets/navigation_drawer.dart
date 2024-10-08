import 'package:flutter/material.dart';

class AppNavigationDrawer extends StatelessWidget {
  final Function(int) onSelectFragment;
  final VoidCallback onNavigateToSecondActivity;

  const AppNavigationDrawer({
    super.key,
    required this.onSelectFragment,
    required this.onNavigateToSecondActivity,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.grey[100],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue[700]!, Colors.blue[900]!],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.blue[900]),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Navigation menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Select an option',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildMenuItem(
              icon: Icons.home,
              title: 'Main',
              onTap: () {
                onSelectFragment(0);
                Navigator.of(context).pop();
              },
            ),
            _buildMenuItem(
              icon: Icons.text_fields,
              title: 'Text',
              onTap: () {
                onSelectFragment(1);
                Navigator.of(context).pop();
              },
            ),
            _buildMenuItem(
              icon: Icons.favorite,
              title: 'Favorite',
              onTap: () {
                onSelectFragment(2);
                Navigator.of(context).pop();
              },
            ),
            Divider(color: Colors.grey[400]),
            _buildMenuItem(
              icon: Icons.launch,
              title: 'Second Activity',
              onTap: () {
                onNavigateToSecondActivity();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[700]),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
      onTap: onTap,
      hoverColor: Colors.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
