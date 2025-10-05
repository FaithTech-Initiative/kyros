
import 'package:flutter/material.dart';
import 'package:kyros/screens/bible_screen.dart';
import 'package:kyros/screens/home_screen.dart';
import 'package:kyros/screens/my_wiki_screen.dart';
import 'package:kyros/screens/note_taking_page.dart';
import 'package:kyros/screens/study_tools_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isSearchActive = false;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    BibleScreen(),
    StudyToolsScreen(),
    MyWikiScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
    });
  }

  void _navigateToNoteEditor() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const NoteTakingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearchActive
            ? const TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
              )
            : const Text('Sermon Notes'),
        actions: [
          IconButton(
            icon: Icon(_isSearchActive ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          const CircleAvatar(
            child: Text('P'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: const Drawer(
        child: Center(
          child: Text('Side Drawer'),
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNoteEditor,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Bible',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Study Tools',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'My Wiki',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
